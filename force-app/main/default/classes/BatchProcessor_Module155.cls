public class BatchProcessor_Module155 implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    private String query;
    private Integer totalProcessed = 0;
    private Integer totalErrors = 0;
    private List<String> errorMessages = new List<String>();
    private Map<String, Integer> statusCounts = new Map<String, Integer>();
    private Datetime startTime;

    public BatchProcessor_Module155() {
        this.query = 'SELECT Id, Name, Industry, AnnualRevenue, BillingCity, BillingState, BillingCountry, Phone, Website, NumberOfEmployees, Description, CreatedDate, LastModifiedDate FROM Account WHERE IsDeleted = false';
        this.startTime = Datetime.now();
    }

    public BatchProcessor_Module155(String customQuery) {
        this.query = customQuery;
        this.startTime = Datetime.now();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO, 'BatchProcessor_Module155.start: Beginning batch execution at ' + String.valueOf(startTime));
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Account> accounts = (List<Account>)scope;
        List<Account> toUpdate = new List<Account>();
        List<Task> tasksToInsert = new List<Task>();

        for (Account acc : accounts) {
            try {
                String status = categorizeAccount(acc);
                if (!statusCounts.containsKey(status)) {
                    statusCounts.put(status, 0);
                }
                statusCounts.put(status, statusCounts.get(status) + 1);
                acc.Description = buildDescription(acc, status);
                toUpdate.add(acc);

                if (shouldCreateFollowUp(acc, status)) {
                    tasksToInsert.add(createFollowUpTask(acc, status));
                }
                totalProcessed++;
            } catch (Exception e) {
                totalErrors++;
                errorMessages.add(acc.Id + ': ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, 'BatchProcessor_Module155.execute error for ' + acc.Id + ': ' + e.getMessage());
            }
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    totalErrors++;
                    for (Database.Error err : results[i].getErrors()) {
                        errorMessages.add(toUpdate[i].Id + ': ' + err.getMessage());
                    }
                }
            }
        }

        if (!tasksToInsert.isEmpty()) {
            Database.insert(tasksToInsert, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        Datetime endTime = Datetime.now();
        Long duration = endTime.getTime() - startTime.getTime();
        String summary = 'BatchProcessor_Module155 Complete | Duration: ' + duration + 'ms | Processed: ' + totalProcessed + ' | Errors: ' + totalErrors + ' | Status: ' + JSON.serialize(statusCounts);
        System.debug(LoggingLevel.INFO, summary);

        if (totalErrors > 0) {
            sendErrorNotification(summary);
        }
        logExecution(bc.getJobId(), summary);
    }

    private String categorizeAccount(Account acc) {
        if (acc.AnnualRevenue == null) return 'Uncategorized';
        if (acc.AnnualRevenue >= 10000000) return 'Enterprise';
        if (acc.AnnualRevenue >= 1000000) return 'MidMarket';
        if (acc.AnnualRevenue >= 100000) return 'SMB';
        return 'Startup';
    }

    private String buildDescription(Account acc, String status) {
        return 'Category: ' + status + ' | Processed: ' + Datetime.now().format() + ' | Revenue: ' + (acc.AnnualRevenue != null ? String.valueOf(acc.AnnualRevenue) : 'N/A') + ' | Employees: ' + (acc.NumberOfEmployees != null ? String.valueOf(acc.NumberOfEmployees) : 'N/A');
    }

    private Boolean shouldCreateFollowUp(Account acc, String status) {
        return status == 'Enterprise' && acc.LastModifiedDate < Datetime.now().addDays(-90);
    }

    private Task createFollowUpTask(Account acc, String status) {
        return new Task(
            Subject = 'Follow up: ' + acc.Name + ' (' + status + ')',
            WhatId = acc.Id,
            ActivityDate = Date.today().addDays(7),
            Priority = 'High',
            Status = 'Not Started',
            Description = 'Auto-generated follow-up for ' + status + ' account not updated in 90+ days.'
        );
    }

    private void sendErrorNotification(String summary) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'admin@example.com'});
        email.setSubject('BatchProcessor_Module155 - Errors Detected');
        email.setPlainTextBody(summary);
        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to send error notification: ' + e.getMessage());
        }
    }

    private void logExecution(Id jobId, String summary) {
        System.debug(LoggingLevel.INFO, 'Job ' + jobId + ': ' + summary);
    }
}

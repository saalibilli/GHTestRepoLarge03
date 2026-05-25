public class ScheduledJob_Process2 implements Schedulable {
    private static final String JOB_NAME = 'ScheduledJob_Process2';

    public void execute(SchedulableContext sc) {
        System.debug(LoggingLevel.INFO, JOB_NAME + ' executing at ' + Datetime.now());

        try {
            // Chain batch jobs
            Database.executeBatch(new BatchProcessor_Module151(), 200);

            // Process platform events
            List<Account> staleAccounts = [
                SELECT Id, Name, LastModifiedDate
                FROM Account
                WHERE LastModifiedDate < :Datetime.now().addDays(-30)
                LIMIT 1000
            ];

            if (!staleAccounts.isEmpty()) {
                System.debug(LoggingLevel.INFO, JOB_NAME + ': Found ' + staleAccounts.size() + ' stale accounts');
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, JOB_NAME + ' failed: ' + e.getMessage());
        }
    }

    public static void scheduleJob() {
        String cronExp = '0 0 2 * * ?'; // 2 AM daily
        System.schedule(JOB_NAME, cronExp, new ScheduledJob_Process2());
    }

    public static void abortJob() {
        for (CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :JOB_NAME]) {
            System.abortJob(ct.Id);
        }
    }
}

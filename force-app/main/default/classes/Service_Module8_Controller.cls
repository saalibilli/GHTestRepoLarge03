public with sharing class Service_Module8_Controller {
    private static final String CLASS_NAME = 'Service_Module8_Controller';
    private static final Integer MAX_RECORDS = 200;
    private static final Integer BATCH_SIZE = 50;

    public class Service_Module8_ControllerException extends Exception {}

    public class DataWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Datetime createdDate { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Map<String, Object> metadata { get; set; }

        public DataWrapper() {
            this.metadata = new Map<String, Object>();
        }

        public DataWrapper(String id, String name, Decimal amount) {
            this();
            this.id = id;
            this.name = name;
            this.amount = amount;
            this.createdDate = Datetime.now();
            this.status = 'Active';
        }
    }

    public interface IProcessor {
        List<DataWrapper> process(List<SObject> records);
        Boolean validate(DataWrapper wrapper);
        void handleError(Exception e, DataWrapper wrapper);
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch1(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus1(wrapper);
                wrapper.metadata.put('source', 'batch1');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '1.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch1: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch1: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 1: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch1: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 1: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus1(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus1(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync1(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 1 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync1 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch2(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus2(wrapper);
                wrapper.metadata.put('source', 'batch2');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '2.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch2: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch2: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 2: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch2: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 2: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus2(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus2(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync2(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 2 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync2 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch3(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus3(wrapper);
                wrapper.metadata.put('source', 'batch3');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '3.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch3: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch3: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 3: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch3: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 3: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus3(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus3(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync3(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 3 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync3 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch4(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus4(wrapper);
                wrapper.metadata.put('source', 'batch4');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '4.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch4: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch4: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 4: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch4: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 4: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus4(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus4(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync4(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 4 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync4 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch5(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus5(wrapper);
                wrapper.metadata.put('source', 'batch5');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '5.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch5: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch5: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 5: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch5: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 5: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus5(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus5(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync5(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 5 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync5 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch6(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus6(wrapper);
                wrapper.metadata.put('source', 'batch6');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '6.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch6: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch6: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 6: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch6: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 6: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus6(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus6(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync6(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 6 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync6 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch7(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus7(wrapper);
                wrapper.metadata.put('source', 'batch7');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '7.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch7: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch7: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 7: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch7: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 7: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus7(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus7(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync7(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 7 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync7 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch8(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus8(wrapper);
                wrapper.metadata.put('source', 'batch8');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '8.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch8: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch8: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 8: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch8: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 8: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus8(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus8(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync8(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 8 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync8 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch9(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus9(wrapper);
                wrapper.metadata.put('source', 'batch9');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '9.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch9: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch9: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 9: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch9: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 9: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus9(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus9(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync9(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 9 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync9 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch10(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus10(wrapper);
                wrapper.metadata.put('source', 'batch10');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '10.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch10: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch10: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 10: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch10: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 10: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus10(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus10(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync10(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 10 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync10 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch11(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus11(wrapper);
                wrapper.metadata.put('source', 'batch11');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '11.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch11: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch11: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 11: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch11: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 11: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus11(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus11(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync11(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 11 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync11 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch12(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus12(wrapper);
                wrapper.metadata.put('source', 'batch12');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '12.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch12: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch12: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 12: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch12: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 12: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus12(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus12(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync12(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 12 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync12 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch13(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus13(wrapper);
                wrapper.metadata.put('source', 'batch13');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '13.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch13: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch13: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 13: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch13: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 13: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus13(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus13(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync13(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 13 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync13 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch14(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus14(wrapper);
                wrapper.metadata.put('source', 'batch14');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '14.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch14: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch14: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 14: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch14: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 14: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus14(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus14(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync14(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 14 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync14 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getRecordsBatch15(String filterField, String filterValue, Integer limitSize) {
        List<DataWrapper> results = new List<DataWrapper>();
        try {
            String queryStr = 'SELECT Id, Name, CreatedDate FROM Account';
            if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
                queryStr += ' WHERE ' + String.escapeSingleQuotes(filterField) + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            queryStr += ' LIMIT ' + (limitSize != null ? limitSize : MAX_RECORDS);

            for (SObject record : Database.query(queryStr)) {
                DataWrapper wrapper = new DataWrapper();
                wrapper.id = (String)record.get('Id');
                wrapper.name = (String)record.get('Name');
                wrapper.createdDate = (Datetime)record.get('CreatedDate');
                wrapper.amount = Decimal.valueOf(Math.random() * 10000).setScale(2);
                wrapper.status = determineStatus15(wrapper);
                wrapper.metadata.put('source', 'batch15');
                wrapper.metadata.put('processedAt', Datetime.now());
                wrapper.metadata.put('version', '15.0');
                results.add(wrapper);
            }

            if (results.isEmpty()) {
                System.debug(LoggingLevel.INFO, CLASS_NAME + '.getRecordsBatch15: No records found for filter ' + filterField + '=' + filterValue);
            }
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch15: Query failed - ' + qe.getMessage());
            throw new Service_Module8_ControllerException('Failed to retrieve records in batch 15: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, CLASS_NAME + '.getRecordsBatch15: Unexpected error - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
            throw new Service_Module8_ControllerException('Unexpected error in batch 15: ' + e.getMessage());
        }
        return results;
    }

    private static String determineStatus15(DataWrapper wrapper) {
        if (wrapper.amount == null) return 'Unknown';
        if (wrapper.amount > 5000) return 'High';
        if (wrapper.amount > 1000) return 'Medium';
        return 'Low';
    }

    public static Map<String, List<DataWrapper>> groupByStatus15(List<DataWrapper> wrappers) {
        Map<String, List<DataWrapper>> grouped = new Map<String, List<DataWrapper>>();
        for (DataWrapper w : wrappers) {
            if (!grouped.containsKey(w.status)) {
                grouped.put(w.status, new List<DataWrapper>());
            }
            grouped.get(w.status).add(w);
        }
        return grouped;
    }

    @future(callout=true)
    public static void processAsync15(Set<Id> recordIds) {
        List<Account> records = [SELECT Id, Name, BillingCity, Industry FROM Account WHERE Id IN :recordIds];
        List<Account> toUpdate = new List<Account>();

        for (Account acc : records) {
            acc.Description = 'Processed by Service_Module8_Controller batch 15 at ' + Datetime.now().format();
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Service_Module8_Controller.processAsync15 failed for ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }
}

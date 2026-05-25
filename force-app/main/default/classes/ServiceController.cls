public with sharing class ServiceController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getRecords(Id recordId, Integer pageSize) {
        if (pageSize == null) pageSize = 25;
        return [SELECT Id, Name, Industry, AnnualRevenue, BillingCity, CreatedDate 
                FROM Account 
                LIMIT :pageSize];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getRecordsPaginated(Id recordId, Integer pageNumber, String sortField, String sortOrder) {
        Integer pageSize = 25;
        Integer offset = (pageNumber != null ? (pageNumber - 1) : 0) * pageSize;
        String query = 'SELECT Id, Name, Industry, AnnualRevenue, BillingCity, CreatedDate FROM Account';
        if (String.isNotBlank(sortField)) {
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + (sortOrder == 'DESC' ? 'DESC' : 'ASC');
        }
        query += ' LIMIT ' + pageSize + ' OFFSET ' + offset;

        Map<String, Object> result = new Map<String, Object>();
        result.put('records', Database.query(query));
        result.put('totalCount', [SELECT COUNT() FROM Account]);
        return result;
    }

    @AuraEnabled
    public static void processRecords(List<Id> recordIds) {
        List<Account> accounts = [SELECT Id, Description FROM Account WHERE Id IN :recordIds];
        for (Account acc : accounts) {
            acc.Description = 'Processed at ' + Datetime.now().format();
        }
        update accounts;
    }

    @AuraEnabled
    public static void deleteRecords(List<Id> recordIds) {
        List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :recordIds];
        delete accounts;
    }
}

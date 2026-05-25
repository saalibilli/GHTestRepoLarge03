@isTest
private class Service_Module14_Controller_Test {

    @TestSetup
    static void setupTestData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                BillingCity = 'City ' + Math.mod(i, 10),
                Industry = Math.mod(i, 2) == 0 ? 'Technology' : 'Finance',
                AnnualRevenue = Math.random() * 100000
            ));
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for (Account acc : accounts) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + acc.Name,
                AccountId = acc.Id,
                Email = 'test' + acc.Name.replaceAll(' ', '') + '@example.com'
            ));
        }
        insert contacts;
    }

    @isTest
    static void testGetRecordsBatch1_WithFilter() {
        Test.startTest();
        List<Service_Module14_Controller.DataWrapper> results = Service_Module14_Controller.getRecordsBatch1('Industry', 'Technology', 100);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return at least one record');
        for (Service_Module14_Controller.DataWrapper w : results) {
            System.assertNotEquals(null, w.id, 'Wrapper id should be populated');
            System.assertNotEquals(null, w.status, 'Status should be determined');
        }
    }

    @isTest
    static void testGetRecordsBatch1_NoFilter() {
        Test.startTest();
        List<Service_Module14_Controller.DataWrapper> results = Service_Module14_Controller.getRecordsBatch1(null, null, 50);
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assert(results.size() <= 50, 'Should respect limit');
    }

    @isTest
    static void testGetRecordsBatch1_EmptyResult() {
        Test.startTest();
        List<Service_Module14_Controller.DataWrapper> results = Service_Module14_Controller.getRecordsBatch1('Name', 'NonExistentAccount99999', 10);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for non-matching filter');
    }

    @isTest
    static void testGroupByStatus1() {
        List<Service_Module14_Controller.DataWrapper> wrappers = new List<Service_Module14_Controller.DataWrapper>();
        wrappers.add(new Service_Module14_Controller.DataWrapper('001', 'High Value', 6000));
        wrappers.add(new Service_Module14_Controller.DataWrapper('002', 'Med Value', 2000));
        wrappers.add(new Service_Module14_Controller.DataWrapper('003', 'Low Value', 500));
        wrappers.add(new Service_Module14_Controller.DataWrapper('004', 'Another High', 8000));

        Test.startTest();
        Map<String, List<Service_Module14_Controller.DataWrapper>> grouped = Service_Module14_Controller.groupByStatus1(wrappers);
        Test.stopTest();

        System.assertEquals(3, grouped.size(), 'Should have 3 status groups');
        System.assertEquals(2, grouped.get('High').size(), 'Should have 2 High records');
    }

    @isTest
    static void testDataWrapperConstructor() {
        Service_Module14_Controller.DataWrapper wrapper = new Service_Module14_Controller.DataWrapper('001', 'Test', 1500.00);

        System.assertEquals('001', wrapper.id);
        System.assertEquals('Test', wrapper.name);
        System.assertEquals(1500.00, wrapper.amount);
        System.assertEquals('Active', wrapper.status);
        System.assertNotEquals(null, wrapper.metadata);
        System.assertNotEquals(null, wrapper.createdDate);
    }

    @isTest
    static void testProcessAsync1() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 10];
        Set<Id> accountIds = new Set<Id>();
        for (Account a : accounts) {
            accountIds.add(a.Id);
        }

        Test.startTest();
        Service_Module14_Controller.processAsync1(accountIds);
        Test.stopTest();

        List<Account> updated = [SELECT Id, Description FROM Account WHERE Id IN :accountIds];
        for (Account acc : updated) {
            System.assert(acc.Description.contains('Processed by Service_Module14_Controller'), 'Description should be updated');
        }
    }

    @isTest
    static void testExceptionHandling() {
        Boolean exceptionThrown = false;
        try {
            Service_Module14_Controller.getRecordsBatch1('InvalidField!!!', 'value', 10);
        } catch (Service_Module14_Controller.Service_Module14_ControllerException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('Failed to retrieve records'), 'Should contain error context');
        }
        System.assert(exceptionThrown, 'Exception should have been thrown for invalid query');
    }
}

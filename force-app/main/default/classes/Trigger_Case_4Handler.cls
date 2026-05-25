public with sharing class Trigger_Case_4Handler {
    public static void handleBeforeInsert(List<SObject> newRecords) {
        for (SObject rec : newRecords) {
            System.debug('Trigger_Case_4Handler.handleBeforeInsert: ' + rec.Id);
        }
    }

    public static void handleBeforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {
        for (SObject rec : newRecords) {
            SObject oldRec = oldMap.get(rec.Id);
            System.debug('Trigger_Case_4Handler.handleBeforeUpdate: ' + rec.Id);
        }
    }

    public static void handleBeforeDelete(List<SObject> oldRecords) {
        for (SObject rec : oldRecords) {
            System.debug('Trigger_Case_4Handler.handleBeforeDelete: ' + rec.Id);
        }
    }

    public static void handleAfterInsert(List<SObject> newRecords) {
        System.debug('Trigger_Case_4Handler.handleAfterInsert: ' + newRecords.size() + ' records');
    }

    public static void handleAfterUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {
        System.debug('Trigger_Case_4Handler.handleAfterUpdate: ' + newRecords.size() + ' records');
    }

    public static void handleAfterDelete(List<SObject> oldRecords) {
        System.debug('Trigger_Case_4Handler.handleAfterDelete: ' + oldRecords.size() + ' records');
    }

    public static void handleAfterUndelete(List<SObject> newRecords) {
        System.debug('Trigger_Case_4Handler.handleAfterUndelete: ' + newRecords.size() + ' records');
    }
}

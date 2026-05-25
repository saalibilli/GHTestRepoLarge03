public with sharing class Trigger_Lead_3Handler {
    public static void handleBeforeInsert(List<SObject> newRecords) {
        for (SObject rec : newRecords) {
            System.debug('Trigger_Lead_3Handler.handleBeforeInsert: ' + rec.Id);
        }
    }

    public static void handleBeforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {
        for (SObject rec : newRecords) {
            SObject oldRec = oldMap.get(rec.Id);
            System.debug('Trigger_Lead_3Handler.handleBeforeUpdate: ' + rec.Id);
        }
    }

    public static void handleBeforeDelete(List<SObject> oldRecords) {
        for (SObject rec : oldRecords) {
            System.debug('Trigger_Lead_3Handler.handleBeforeDelete: ' + rec.Id);
        }
    }

    public static void handleAfterInsert(List<SObject> newRecords) {
        System.debug('Trigger_Lead_3Handler.handleAfterInsert: ' + newRecords.size() + ' records');
    }

    public static void handleAfterUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {
        System.debug('Trigger_Lead_3Handler.handleAfterUpdate: ' + newRecords.size() + ' records');
    }

    public static void handleAfterDelete(List<SObject> oldRecords) {
        System.debug('Trigger_Lead_3Handler.handleAfterDelete: ' + oldRecords.size() + ' records');
    }

    public static void handleAfterUndelete(List<SObject> newRecords) {
        System.debug('Trigger_Lead_3Handler.handleAfterUndelete: ' + newRecords.size() + ' records');
    }
}

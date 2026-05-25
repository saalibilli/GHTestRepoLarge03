trigger Trigger_Contact_1 on Contact (before insert, before update, after insert, after update, before delete, after delete, after undelete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Trigger_Contact_1Handler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Trigger_Contact_1Handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            Trigger_Contact_1Handler.handleBeforeDelete(Trigger.old);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Trigger_Contact_1Handler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Trigger_Contact_1Handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            Trigger_Contact_1Handler.handleAfterDelete(Trigger.old);
        } else if (Trigger.isUndelete) {
            Trigger_Contact_1Handler.handleAfterUndelete(Trigger.new);
        }
    }
}

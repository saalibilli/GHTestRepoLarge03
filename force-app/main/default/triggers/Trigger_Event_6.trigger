trigger Trigger_Event_6 on Event (before insert, before update, after insert, after update, before delete, after delete, after undelete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Trigger_Event_6Handler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Trigger_Event_6Handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            Trigger_Event_6Handler.handleBeforeDelete(Trigger.old);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Trigger_Event_6Handler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Trigger_Event_6Handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            Trigger_Event_6Handler.handleAfterDelete(Trigger.old);
        } else if (Trigger.isUndelete) {
            Trigger_Event_6Handler.handleAfterUndelete(Trigger.new);
        }
    }
}

trigger Trigger_Opportunity_12 on Opportunity (before insert, before update, after insert, after update, before delete, after delete, after undelete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Trigger_Opportunity_12Handler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Trigger_Opportunity_12Handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            Trigger_Opportunity_12Handler.handleBeforeDelete(Trigger.old);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Trigger_Opportunity_12Handler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Trigger_Opportunity_12Handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            Trigger_Opportunity_12Handler.handleAfterDelete(Trigger.old);
        } else if (Trigger.isUndelete) {
            Trigger_Opportunity_12Handler.handleAfterUndelete(Trigger.new);
        }
    }
}

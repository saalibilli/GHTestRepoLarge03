trigger Trigger_Opportunity_2 on Opportunity (before insert, before update, after insert, after update, before delete, after delete, after undelete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Trigger_Opportunity_2Handler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Trigger_Opportunity_2Handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            Trigger_Opportunity_2Handler.handleBeforeDelete(Trigger.old);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Trigger_Opportunity_2Handler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Trigger_Opportunity_2Handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            Trigger_Opportunity_2Handler.handleAfterDelete(Trigger.old);
        } else if (Trigger.isUndelete) {
            Trigger_Opportunity_2Handler.handleAfterUndelete(Trigger.new);
        }
    }
}

trigger CaseTrigger on Case (before insert, after insert, before update, after update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        CaseTriggerService.checkIfCaseAdmin(Trigger.New);
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        if(!CaseTriggerService.isRecursiveBehaviour){
            CaseTriggerService.createNonconformance(Trigger.New);
        }
    }
}
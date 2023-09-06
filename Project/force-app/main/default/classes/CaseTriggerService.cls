public with sharing class CaseTriggerService {
    @TestVisible
    private static final String TYPE_PROBLEM = 'Problem';
    @TestVisible
    private static final String CASE_ADMIN_PERMISSION_SET = 'Case_Admin';
    
    public static Boolean isRecursiveBehaviour = false;
    
    public static void checkIfCaseAdmin(List<Case> cases){
        Boolean isCaseAdmin = checkCaseAdmin();
        for(Case casee : cases){
            if( !isCaseAdmin && casee.Type == TYPE_PROBLEM){
                casee.addError(Label.CaseAdminErrorLbl);
            }
        }
    }
    
    public static void createNonconformance(List<Case> cases){
        isRecursiveBehaviour = true;
        List<SQX_Nonconformance__c> nonconformances = new List<SQX_Nonconformance__c>();
        Boolean isCaseAdmin = checkCaseAdmin();
        for(Case casee : cases){
            if(casee.Type == TYPE_PROBLEM && casee.SQX_NC_Reference__c == null && isCaseAdmin){
                nonconformances.add(
                	new SQX_Nonconformance__c(
                        Priority__c = casee.Priority,
                        Title__c = casee.Subject,
                        Description__c = casee.Description,
                        QMS_Reference_Numbe__c = casee.CaseNumber
                    )
                );
            }
        }
        
        if(nonconformances != null && nonconformances.size() > 0){
            insert nonconformances;
        }
        
        Map<String, Id> nonconformanceByCasenumber = getNonconformanceByCaseNumber(nonconformances);
        List<Case> casesToUpdate = new List<Case>();
        for(Case casee : cases){
            if(casee.SQX_NC_Reference__c == null){
                casesToUpdate.add(new Case(Id = casee.Id, SQX_NC_Reference__c = nonconformanceByCasenumber.get(casee.CaseNumber)));
            }
        }
        
        if(casesToUpdate != null && casesToUpdate.size() > 0){
            update casesToUpdate;
        }
    }
    
    private static Map<String, Id> getNonconformanceByCaseNumber(List<SQX_Nonconformance__c> nonconformances){
        Map<String, Id> nonconformanceByCaseNumber = new Map<String, Id>();
        for(SQX_Nonconformance__c nonconformance : [SELECT Id, QMS_Reference_Numbe__c FROM SQX_Nonconformance__c WHERE Id IN :nonconformances] ){
            nonconformanceByCaseNumber.put(nonconformance.QMS_Reference_Numbe__c, nonconformance.Id);
        }
        
        return nonconformanceByCaseNumber;
    }
    
    private static Boolean checkCaseAdmin(){
        return [SELECT Id 
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId() AND
                PermissionSet.Name = :CASE_ADMIN_PERMISSION_SET]?.size() > 0;
    }
}
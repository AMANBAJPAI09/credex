@IsTest
private class CaseTriggerTest {
    @IsTest
    static void ifCaseAdminNotAssignedThenNoCaseCreated(){
        User stdUser = makeUser();
        System.runAs(stdUser){
            String exceptionMsg;
            Boolean isExceptionCaught = false;
            Test.startTest();
            try{
                insert makeCase();
            }
            catch(Exception e){
                exceptionMsg = e.getMessage();
                isExceptionCaught = true;
            }
            Test.stopTest();
            System.assertEquals(true, [SELECT Id FROM Case].size() == 0);
            System.assertEquals(true, exceptionMsg.contains(Label.CaseAdminErrorLbl));
            System.assertEquals(true, isExceptionCaught);
        }
        
    }
    
    @IsTest
    static void caseCreatedSinceCaseAdminPermissionSetAssigned(){
        User stdUser = makeUser();
        assignCaseAdminPermissionSet(stdUser);
        System.runAs(stdUser){
            Test.startTest();
           	Case testCase = makeCase();
            insert testCase;
            testCase.Reason = 'Installation';
            update testCase; // To check that there should only be one nonconformance
            Test.stopTest();
            Case casee = [SELECT Priority, Subject, Description, CaseNumber FROM Case WHERE Id = :testCase.Id];
            List<SQX_Nonconformance__c> noncoformance = [SELECT Priority__c, Title__c, Description__c, QMS_Reference_Numbe__c from SQX_Nonconformance__c WHERE QMS_Reference_Numbe__c = :casee.CaseNumber];
            System.assertEquals(true, casee != null, 'Case should get created');
            System.assertEquals(true, noncoformance != null, 'Nonconformance should get created');
            System.assertEquals(true, noncoformance.size() == 1, 'There should only be only one nonconformance');
            System.assertEquals(noncoformance[0].Priority__c, casee.Priority, 'nonconformance should have same priority');
            System.assertEquals(noncoformance[0].Description__c, casee.Description, 'nonconformance should have same description');
            System.assertEquals(noncoformance[0].QMS_Reference_Numbe__c, casee.CaseNumber, 'nonconformance QMS_Reference_Numbe__c should be same as case number');
        }
    }
    
    static User makeUser(){
        User stdUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User']?.Id,
            LastName = 'last',
            Email = 'test.user@gamil.com',
            Username = 'test.user@gamil.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        insert stdUser;
        return stdUser;
    }
    
    static void assignCaseAdminPermissionSet(User user){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :CaseTriggerService.CASE_ADMIN_PERMISSION_SET];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
    }
    
    static Case makeCase(){
        return new Case(Type = CaseTriggerService.TYPE_PROBLEM, Status = 'New', Origin = 'Web');
    }
}
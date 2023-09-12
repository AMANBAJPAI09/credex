@IsTest
private class CaseTriggerTest {
 @testsetup
    static void createTestData(){
        User stdUser1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User']?.Id,
            LastName = 'last1',
            Email = 'test.user@gamil.com',
            Username = 'test.user1@gamil.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );        
        insert stdUser1;
        User stdUser2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User']?.Id,
            LastName = 'last2',
            Email = 'test.user2@gamil.com',
            Username = 'test.user@gamil.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );        
        insert stdUser2;
       assignCaseAdminPermissionSet(stdUser2);       
    }
    @IsTest
    static void ifCaseAdminNotAssignedThenNoCaseCreated(){
        User objUser = [Select id from User where LastName ='last1'];
        System.runAs(objUser){
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
    static void caseInsertCheckMethod(){
        User objUser2 = [Select id from User where LastName ='last2'];
        System.runAs(objUser2){
            Test.startTest();
            Case testCase = makeCase();
            insert testCase;
            Test.stopTest();
            Case casee = [SELECT Priority, Subject, Description, CaseNumber FROM Case WHERE Id = :testCase.Id];
            List<SQX_Nonconformance__c> noncoformance = [SELECT Priority__c, Title__c, Description__c, QMS_Reference_Number__c from SQX_Nonconformance__c WHERE QMS_Reference_Number__c = :casee.CaseNumber];
            System.assertEquals(true, casee != null, 'Case should get created');
            System.assertEquals(true, noncoformance != null, 'Nonconformance should get created');
            System.assertEquals(true, noncoformance.size() == 1, 'There should only be only one nonconformance');
            System.assertEquals(noncoformance[0].Priority__c, casee.Priority, 'nonconformance should have same priority');
            System.assertEquals(noncoformance[0].Description__c, casee.Description, 'nonconformance should have same description');
            System.assertEquals(noncoformance[0].QMS_Reference_Number__c, casee.CaseNumber, 'nonconformance QMS_Reference_Number__c should be same as case number');
        }
    } 
    @IsTest
    static void caseInsertUpdateCheckMethod(){
        User objUser2 = [Select id from User where LastName ='last2'];
        System.runAs(objUser2){
            Test.startTest();
            Case testCase = makeCase();
            insert testCase;
            // To check that there should only be one nonconformance even after update of case
            testCase.Reason = 'Installation';
            testCase.Type = 'Mechanical';            
            update testCase; 
            Test.stopTest();
            Case casee = [SELECT Priority, Type, Subject, Description, CaseNumber FROM Case WHERE Id = :testCase.Id];
            List<SQX_Nonconformance__c> noncoformance = [SELECT Priority__c, Title__c, Description__c, QMS_Reference_Number__c from SQX_Nonconformance__c WHERE QMS_Reference_Number__c = :casee.CaseNumber];
            System.assertEquals(true, casee != null, 'Case should get created');
            System.assertEquals(true, noncoformance != null, 'Nonconformance should get created');
            //Below assert will check if the noncoformance is still 1 for the case as we changed the Type
            System.assertEquals(true, noncoformance.size() == 1, 'There should only be only one nonconformance');
            System.assertEquals(noncoformance[0].Priority__c, casee.Priority, 'nonconformance should have same priority');
            System.assertEquals(noncoformance[0].Description__c, casee.Description, 'nonconformance should have same description');
            System.assertEquals(noncoformance[0].QMS_Reference_Number__c, casee.CaseNumber, 'nonconformance QMS_Reference_Number__c should be same as case number');
        }
    }
    static void assignCaseAdminPermissionSet(User user){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :CaseTriggerService.CASE_ADMIN_PERMISSION_SET];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
    }
    
    static Case makeCase(){
        return new Case(Type = CaseTriggerService.TYPE_PROBLEM, Status = 'New', Origin = 'Web');
    }
}

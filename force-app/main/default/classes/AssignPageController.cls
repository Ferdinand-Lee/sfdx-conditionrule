public with sharing class AssignPageController {
    @RemoteAction
    public static Map<String, Object> init(){
        Map<String, Object> result = new Map<String, Object>();
        result.put('rules', [SELECT Id, 
                                    AssignTo__c,
                                    AssignedCount__c,
                                    Logic__c,
                                    Size__c,
                                    SObjectType__c,
                                    Field_0__c, Option_0__c, Value_0__c,
                                    Field_1__c, Option_1__c, Value_1__c,
                                    Field_2__c, Option_2__c, Value_2__c,
                                    Field_3__c, Option_3__c, Value_3__c,
                                    Field_4__c, Option_4__c, Value_4__c,
                                    Field_5__c, Option_5__c, Value_5__c,
                                    Field_6__c, Option_6__c, Value_6__c,
                                    Field_7__c, Option_7__c, Value_7__c
                             FROM ConditionRule__c]);
        return result;
    }

    @RemoteAction
    public static void save(List<ConditionRule__c> rules){
        upsert rules;
    }
}

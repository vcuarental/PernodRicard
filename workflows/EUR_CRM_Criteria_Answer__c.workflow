<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_CRM_Update_Criteria_isChanged_Status</fullName>
        <description>Update Criteria Threshold isChanged to true</description>
        <field>EUR_CRM_isChanged__c</field>
        <literalValue>1</literalValue>
        <name>EUR CRM Update Criteria isChanged Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>EUR_CRM_Criteria_Threshold__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>EUR CRM Update Criteria Threshold isChanged Field</fullName>
        <actions>
            <name>EUR_CRM_Update_Criteria_isChanged_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( !ISNEW(), OR( ISCHANGED( EUR_CRM_Weight__c ),ISCHANGED( EUR_CRM_Base_Integer__c)) ,  EUR_CRM_Criteria_Threshold__r.EUR_CRM_isChanged__c = false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_CRM_Set_Quiz_Active_indicator</fullName>
        <field>EUR_CRM_IsActive__c</field>
        <literalValue>1</literalValue>
        <name>Set Quiz Active indicator</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Set_Quiz_Inactive_indicator</fullName>
        <field>EUR_CRM_IsActive__c</field>
        <literalValue>0</literalValue>
        <name>Set Quiz Inactive indicator</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR_CRM_Update Quiz Active indicator</fullName>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_CRM_Set_Quiz_Inactive_indicator</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>EUR_CRM_Quiz__c.EUR_CRM_EndDate__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_CRM_Set_Quiz_Active_indicator</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>EUR_CRM_Quiz__c.EUR_CRM_StartDate__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>

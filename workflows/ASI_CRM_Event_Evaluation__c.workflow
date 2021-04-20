<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Event_Eval_Set_Completed_Date</fullName>
        <field>ASI_CRM_CN_Completed_Date__c</field>
        <formula>NOW()</formula>
        <name>Event Evaluation - Set Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_Event_Eval_Set_Completed_Date_WF</fullName>
        <actions>
            <name>ASI_CRM_CN_Event_Eval_Set_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Event_Evaluation__c.ASI_CRM_CN_Status__c</field>
            <operation>equals</operation>
            <value>已評估</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_MY_Update_Region_ActualOff</fullName>
        <field>ASI_CRM_Branch__c</field>
        <formula>ASI_CRM_Branch__c</formula>
        <name>ASI_CRM_MY_Update_Region_ActualOff</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_MY_Update_Region_ActualOff</fullName>
        <actions>
            <name>ASI_CRM_MY_Update_Region_ActualOff</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TH_CRM_Actual_Offtake__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Actual Offtake (MY)</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

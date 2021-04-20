<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_MY_Update_Region_Supplier</fullName>
        <field>ASI_CRM_Branch__c</field>
        <formula>ASI_CRM_Outlet__r.ASI_CRM_MY_Branch__c</formula>
        <name>ASI_CRM_MY_Update_Region_Supplier</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_MY_Update_Region_Supplier</fullName>
        <actions>
            <name>ASI_CRM_MY_Update_Region_Supplier</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Supplier__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Supplier (MY)</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

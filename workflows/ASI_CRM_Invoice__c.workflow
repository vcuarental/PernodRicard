<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Invoice_Payment_Date_Update</fullName>
        <field>ASI_CRM_Payment_Date__c</field>
        <formula>today()</formula>
        <name>ASI_CRM_SG_Invoice_Payment_Date_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_SG_Invoice_Payment_Date</fullName>
        <actions>
            <name>ASI_CRM_SG_Invoice_Payment_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Invoice__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG CRM Invoice</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_Invoice__c.ASI_CRM_Open_Amount__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

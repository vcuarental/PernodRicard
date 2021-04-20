<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_ISP_Settlement</fullName>
        <field>EUR_ISP_Invoice_Number_Invoice_Date__c</field>
        <formula>TEXT(EUR_ISP_Vendor_Invoice_Date__c) + EUR_ISP_Vendor_Invoice_Number__c</formula>
        <name>EUR ISP Settlement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR_ISP_Settlement</fullName>
        <actions>
            <name>EUR_ISP_Settlement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_ISP_Settlement__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>iSpend Settlement</value>
        </criteriaItems>
        <description>Will prove if the vendor invoice number and date is unique.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

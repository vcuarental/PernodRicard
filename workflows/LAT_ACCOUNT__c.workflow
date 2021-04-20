<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LAT_Acc_SetIDStatusInactive</fullName>
        <description>Sets the ID Status field on LAT_Account Object to &apos;Inactive&apos;</description>
        <field>LAT_ID_Status__c</field>
        <literalValue>Inactivo</literalValue>
        <name>LAT Acc Set ID Status Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_MX_SetDefaultIdStatus</fullName>
        <actions>
            <name>LAT_Acc_SetIDStatusInactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>MX Off-Trade</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

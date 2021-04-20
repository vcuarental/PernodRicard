<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Credit_Note_Item_Detail_Draft</fullName>
        <field>ASI_CRM_SG_Credit_Note_Header_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Update Credit Note Item Detail to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM SG Update Credit Note Item Detail upon CREATION</fullName>
        <actions>
            <name>ASI_CRM_SG_Credit_Note_Item_Detail_Draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_SG_Credit_Note_Item_Detail__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Credit Note Item Detail</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

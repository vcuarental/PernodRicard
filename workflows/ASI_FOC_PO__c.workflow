<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_FOC_Copy_PO_External_Id</fullName>
        <field>ASI_FOC_PO_External_ID__c</field>
        <formula>Name</formula>
        <name>Copy PO External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI FOC Update PO External Id</fullName>
        <actions>
            <name>ASI_FOC_Copy_PO_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_FOC_PO__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>For FOC integration purpose</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

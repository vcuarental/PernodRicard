<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>RIC_ValeurUDC_Name</fullName>
        <field>Name</field>
        <formula>RIC_Code__c &amp; &quot;-&quot; &amp; RIC_Description__c</formula>
        <name>RIC_ValeurUDC_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>RIC_ValeurUDC_Name</fullName>
        <actions>
            <name>RIC_ValeurUDC_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWF__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Concatène le Code et la Description dans le Name</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

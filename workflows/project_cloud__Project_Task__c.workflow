<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>project_cloud__Append_Task_Number</fullName>
        <description>Field Update action for the Append Task Number workflow rule</description>
        <field>Name</field>
        <formula>/*Trim the Name to 67 characters because the Max length of the Name is 80. The Task number is 10 characters and 3 characters for the spacer*/
LEFT(Name, 67) + &apos; - &apos; + project_cloud__Task_Number__c</formula>
        <name>Append Task Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>project_cloud__Append Task Number</fullName>
        <actions>
            <name>project_cloud__Append_Task_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Appends the Project Task&apos;s Auto Number to the Name field</description>
        <formula>RIGHT(Name, 3 + LEN(project_cloud__Task_Number__c)) != &apos; - &apos; + project_cloud__Task_Number__c</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_KOR_Bar_Styling_Item_Name_Update</fullName>
        <field>ASI_KOR_Item_Name_Copied__c</field>
        <formula>ASI_KOR_Item_Name__r.Name</formula>
        <name>ASI KOR Bar-Styling Item Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI KOR Bar-Styling Item Name Copy</fullName>
        <actions>
            <name>ASI_KOR_Bar_Styling_Item_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL(ASI_KOR_Item_Name__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

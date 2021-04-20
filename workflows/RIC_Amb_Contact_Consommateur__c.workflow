<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>RIC_Amb_Update_Contact_Name</fullName>
        <field>Name</field>
        <formula>RIC_Amb_Prenom_du_contact__c &amp;&quot; &quot;&amp; RIC_Amb_Nom_du_contact__c</formula>
        <name>Update Contact Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>RIC_Amb_Set_Name</fullName>
        <actions>
            <name>RIC_Amb_Update_Contact_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RIC_Amb_Contact_Consommateur__c.RIC_Amb_Prenom_du_contact__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_TnE_TW_Set_Name_Company_Concat</fullName>
        <field>ASI_TnE_Name_Company__c</field>
        <formula>ASI_TnE_Name_Company__c &amp; &quot; - &quot; &amp; ASI_TnE_Transaction_Currency__c &amp; &quot; &quot; &amp; TEXT(ASI_TnE_Transaction_Amount__c)</formula>
        <name>Set Name &amp; Company by Concat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_TnE_TW_Corp_Card_Concat_Fields</fullName>
        <actions>
            <name>ASI_TnE_TW_Set_Name_Company_Concat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TnE_Corp_Card_Statement_Upload__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI TnE TW Corp Card Upload</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_TnE_Corp_Card_Statement_Upload__c.ASI_TnE_Transaction_Currency__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_TnE_Corp_Card_Statement_Upload__c.ASI_TnE_Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Concat the Transaction Currency and Transaction Amount</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

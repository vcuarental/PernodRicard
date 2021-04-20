<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_ISP_UserAccount</fullName>
        <field>EUR_ISP_Cust_Ext_ID_Account_User_Usernam__c</field>
        <formula>CASESAFEID (EUR_ISP_Account__r.Id) + EUR_ISP_User__r.Username</formula>
        <name>EUR ISP UserAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR_ISP_UserAccount</fullName>
        <actions>
            <name>EUR_ISP_UserAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Will prove if the Account SF ID and Username are unique.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>GRP_CC_Closing_date</fullName>
        <field>GRP_CC_Closing_date__c</field>
        <formula>TODAY ()</formula>
        <name>GRP_CC_Closing date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>GRP_CC_MAJ Closing date</fullName>
        <actions>
            <name>GRP_CC_Closing_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>GRP_CC_Deep_dive__c.GRP_CC_Statut__c</field>
            <operation>equals</operation>
            <value>Done</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

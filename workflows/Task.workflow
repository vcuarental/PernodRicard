<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LAT_TipoUpdate</fullName>
        <field>LAT_Tipo__c</field>
        <literalValue>Seguimiento de pendientes</literalValue>
        <name>LAT_TipoUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TSK_TruncateDescription</fullName>
        <description>Setup - Truncate the Description field in the technical field Truncated Description to be used in the Timeline bubbles.</description>
        <field>TECH_TruncatedDescription__c</field>
        <formula>LEFT( Description , $Setup.CS001_TimelineConfig__c.TaskDescriptionTeaserLength__c ) + &quot;...&quot;</formula>
        <name>TSK_TruncateDescription</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT Tipo Seguimiento</fullName>
        <actions>
            <name>LAT_TipoUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seguimiento de pendientes</value>
        </criteriaItems>
        <description>This rule populates the LAT_Tipo__c field when the RecordType is LAT_SeguimientoPendientes</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>TSK_TruncateDescription</fullName>
        <actions>
            <name>TSK_TruncateDescription</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Setup - Truncate the Description field in the technical field Truncated Description to be used in the Timeline bubbles.</description>
        <formula>ISCHANGED( Description )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

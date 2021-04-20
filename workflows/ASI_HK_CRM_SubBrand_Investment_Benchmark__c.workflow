<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Update_PAF_INV_Bench_ID</fullName>
        <description>Set value of ASI_HK_CRM_INV_Benchmark_Unique_ID__c  by concat Local Channel and Sub-Brand values</description>
        <field>ASI_HK_CRM_INV_Benchmark_Unique_ID__c</field>
        <formula>ASI_HK_CRM_Sub_Brand__r.Name 
+ &quot; - &quot;
+ TEXT(ASI_HK_CRM_Local_Channel__c)</formula>
        <name>ASI HK CRM - Update PAF INV Bench ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI HK CRM Populate PAF Sub-Brand INV Benchmark Unique ID</fullName>
        <actions>
            <name>ASI_HK_CRM_Update_PAF_INV_Bench_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate ASI_HK_CRM_INV_Benchmark_Unique_ID__c with concatenation of Sub-Brand and Local Channel values</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

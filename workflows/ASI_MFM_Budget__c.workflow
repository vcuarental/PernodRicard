<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_MFM_Set_On_Syn_to_DW_for_Budget</fullName>
        <field>ASI_MFM_Sync_to_DW__c</field>
        <literalValue>1</literalValue>
        <name>Set On Syn to DW for Budget</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_Set_Budget_Sync_Flag</fullName>
        <actions>
            <name>ASI_MFM_Set_On_Syn_to_DW_for_Budget</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Budget__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CAN_End_date_update</fullName>
        <field>gvp__End_Date__c</field>
        <formula>Closed_By_Date__c</formula>
        <name>End date update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Objective_Put_Product_Level_in_Custom_1</fullName>
        <field>gvp__Custom_1__c</field>
        <formula>Product_Level__c</formula>
        <name>Objective: Put Product Level in Custom 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Objective_Set_Custom_2_to_Active</fullName>
        <field>gvp__Custom_2__c</field>
        <formula>&quot;Active&quot;</formula>
        <name>Objective: Set Custom 2 to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Objective_Set_Custom_2_to_Inactive</fullName>
        <field>gvp__Custom_2__c</field>
        <formula>&quot;Inactive&quot;</formula>
        <name>Objective: Set Custom 2 to Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Objective_Set_Custom_3_to_Program_Name</fullName>
        <field>gvp__Custom_3__c</field>
        <formula>gvp__Program__r.Name</formula>
        <name>Objective: Set Custom 3 to Program Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Objective_Set_Custom_3_to_UserObjective</fullName>
        <field>gvp__Custom_3__c</field>
        <formula>&quot;UserObjective&quot;</formula>
        <name>Objective: Set Custom 3 to UserObjective</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Objective_Key_from_Autonumber</fullName>
        <field>Objective_Key__c</field>
        <formula>Name</formula>
        <name>Update Objective Key from Autonumber</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <field>gvp__Status__c</field>
        <literalValue>Closed - Time Expired</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status1</fullName>
        <field>gvp__Status__c</field>
        <literalValue>Closed - Time Expired</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CAN_Objective%3A End date %3D Closed by date</fullName>
        <actions>
            <name>CAN_End_date_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__Account_Objective__c.Closed_By_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Objective%3A Populate Objective Key</fullName>
        <actions>
            <name>Update_Objective_Key_from_Autonumber</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__Account_Objective__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Objective%3A Put Product Level in Custom 1</fullName>
        <actions>
            <name>Objective_Put_Product_Level_in_Custom_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__Account_Objective__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Objective%3A Set Custom 2 to Active</fullName>
        <actions>
            <name>Objective_Set_Custom_2_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__Account_Objective__c.gvp__Accomplish_by__c</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Objective%3A Set Custom 2 to Inactive</fullName>
        <active>false</active>
        <criteriaItems>
            <field>gvp__Account_Objective__c.gvp__Accomplish_by__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>gvp__Account_Objective__c.gvp__Accomplish_by__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Objective%3A Set Custom 3 to Program Name</fullName>
        <actions>
            <name>Objective_Set_Custom_3_to_Program_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>gvp__Program__r.Name = &quot;CorpObjectives&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Objective%3A Set Custom 3 to Program Name UserObjective</fullName>
        <actions>
            <name>Objective_Set_Custom_3_to_UserObjective</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>gvp__Program__r.Name &lt;&gt; &quot;CorpObjectives&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

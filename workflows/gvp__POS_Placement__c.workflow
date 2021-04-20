<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CAN_GVP_End_Date_c</fullName>
        <description>CA Racks - End Date to custom 2</description>
        <field>gvp__Custom_2__c</field>
        <formula>IF (ISNULL(GVP_End_Date__c), &apos;&apos;,
TEXT(MONTH(GVP_End_Date__c))+&quot;/&quot; +TEXT(DAY(GVP_End_Date__c))+&quot;/&quot; +TEXT(YEAR(GVP_End_Date__c))
)</formula>
        <name>CA Racks - End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAN_RACK_START_DATE</fullName>
        <field>gvp__Date_Delivered__c</field>
        <formula>GVP_Start_Date__c</formula>
        <name>CA_RACK_START_DATE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAN_RACK_STATUS</fullName>
        <description>CORBY Racks GVP_Status__c to custom 3</description>
        <field>gvp__Custom_3__c</field>
        <formula>TEXT( GVP_Status__c)</formula>
        <name>CA_RACK STATUS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAN_RackAssignment_duration_to_custom_1</fullName>
        <description>CA - Rack Assignment duration non gvp field update to custom 1</description>
        <field>gvp__Custom_1__c</field>
        <formula>TEXT(GVP_Assignment_Duration__c)</formula>
        <name>CA - RackAssignment duration to custom 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAN_Racks_days_active_to_custom_fact_1</fullName>
        <description>CAN Racks days active to custom fact 1</description>
        <field>gvp__Custom_Fact_1__c</field>
        <formula>GVP_Days_between_start_and_end__c</formula>
        <name>CAN Racks days active to custom fact 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAN_Status_Change</fullName>
        <description>Change the Status to close if the end date is less or equal to today</description>
        <field>GVP_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>CAN Status Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <description>Update Rack placement Status</description>
        <field>GVP_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CAN Assignment Duration</fullName>
        <actions>
            <name>CAN_RackAssignment_duration_to_custom_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__POS_Placement__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update non gvp field Assignment Duration to the GVP Field Custom 1</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CAN Racks End Date</fullName>
        <actions>
            <name>CAN_GVP_End_Date_c</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__POS_Placement__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update non gvp field GVP_End_Date__c to the GVP Field Custom 2</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CAN Racks days active to custom fact 1</fullName>
        <actions>
            <name>CAN_Racks_days_active_to_custom_fact_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__POS_Placement__c.GVP_Days_between_start_and_end__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>CAN Racks days active to custom fact 1</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CAN Racks status</fullName>
        <actions>
            <name>CAN_RACK_STATUS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__POS_Placement__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update non gvp field GVP_Status__c to the GVP Field Custom 3</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CAN Status changes</fullName>
        <actions>
            <name>CAN_Status_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__POS_Placement__c.GVP_End_Date__c</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>If the End Date is less than today, auto change the status to closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>gvp__POS_Placement__c.GVP_End_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CAN_RACK_START_DATE</fullName>
        <actions>
            <name>CAN_RACK_START_DATE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>gvp__POS_Placement__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

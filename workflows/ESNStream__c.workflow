<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_1_day_after_the_stream_end_date</fullName>
        <description>Email 1 day after the stream end date</description>
        <protected>false</protected>
        <recipients>
            <field>ProjectManagerEmailStream__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>StreamLeaderEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Tab/Third_level_alert_stream</template>
    </alerts>
    <alerts>
        <fullName>Email_1_day_after_the_stream_start_date</fullName>
        <description>Email 1 day after the stream start date</description>
        <protected>false</protected>
        <recipients>
            <field>ProjectManagerEmailStream__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>StreamLeaderEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Tab/Second_level_alert_stream</template>
    </alerts>
    <alerts>
        <fullName>Email_3_days_before_the_stream_start_date</fullName>
        <description>Email 3 days before the stream start date</description>
        <protected>false</protected>
        <recipients>
            <field>StreamLeaderEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Tab/First_level_alert_stream</template>
    </alerts>
    <fieldUpdates>
        <fullName>ESN_FU001_PlannedDeadlineToStartDate</fullName>
        <field>StartDate__c</field>
        <formula>ESN_PlannedDeadline__c</formula>
        <name>ESN_FU001_PlannedDeadlineToStartDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU002_PlannedDeadlineToEndDate</fullName>
        <field>EndDate__c</field>
        <formula>ESN_PlannedDeadline__c</formula>
        <name>ESN_FU002_PlannedDeadlineToEndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU005_ChangeStatusToCompleted</fullName>
        <description>Changes the Project Plan Status to Closed.</description>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>ESN_FU005_ChangeStatusToCompleted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU006_ChangeStatusToOpen</fullName>
        <description>Changes the Project Plan Status to Open.</description>
        <field>Status__c</field>
        <literalValue>Open</literalValue>
        <name>ESN_FU006_ChangeStatusToOpen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU007_PlannedDeadlineToStartDate</fullName>
        <field>StartDate__c</field>
        <formula>ESN_PlannedDeadline__c</formula>
        <name>ESN_FU007_PlannedDeadlineToStartDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU008_PlannedDeadlineToEndDate</fullName>
        <field>EndDate__c</field>
        <formula>ESN_PlannedDeadline__c</formula>
        <name>ESN_FU008_PlannedDeadlineToEndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU009_ActualDeadlineToStartDate</fullName>
        <field>ESN_ActualStartDate__c</field>
        <formula>ESN_ActualDeadline__c</formula>
        <name>ESN_FU009_ActualDeadlineToStartDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU010_ActualDeadlineToEndDate</fullName>
        <field>EndDate__c</field>
        <formula>ESN_ActualEndDate__c</formula>
        <name>ESN_FU010_ActualDeadlineToEndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU011_ActualDeadLineEqualsPlanned</fullName>
        <field>ESN_ActualDeadline__c</field>
        <formula>ESN_PlannedDeadline__c</formula>
        <name>ESN_FU011_ActualDeadLineEqualsPlanned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU012_ActualStartDateEqualsPlanned</fullName>
        <field>ESN_ActualStartDate__c</field>
        <formula>StartDate__c</formula>
        <name>ESN_FU012_ActualStartDateEqualsPlanned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU013_ActualEndDateEqualsPlanned</fullName>
        <field>ESN_ActualEndDate__c</field>
        <formula>EndDate__c</formula>
        <name>ESN_FU013_ActualEndDateEqualsPlanned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContributor1EmailStream</fullName>
        <field>Contributor1EmailStream__c</field>
        <formula>Project__r.Contributor1Email__c</formula>
        <name>Update contributor # 1  email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContributor2EmailStream</fullName>
        <field>Contributor2EmailStream__c</field>
        <formula>Project__r.Contributor2Email__c</formula>
        <name>Update contributor # 2  email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateProjectManagerEmailStream</fullName>
        <field>ProjectManagerEmailStream__c</field>
        <formula>Project__r.ProjectManagerEmail__c</formula>
        <name>Update project manager email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateSponsorEmail</fullName>
        <field>SponsorEmailStream__c</field>
        <formula>Project__r.SponsorEmail__c</formula>
        <name>Update sponsor email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStreamLeaderEmail</fullName>
        <field>StreamLeaderEmail__c</field>
        <formula>StreamLeader__r.Email</formula>
        <name>Update stream leader email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ESN_WKF002_ProjectPlan_Milestone_UpdateStatusOnCompleted</fullName>
        <actions>
            <name>ESN_FU005_ChangeStatusToCompleted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ESNStream__c.ESN_Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ESNStream__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone</value>
        </criteriaItems>
        <description>(Consistency WKF): Changes the Project Plan Status to Completed when the Milestone is checked as Completed = True.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ESN_WKF003_ProjectPlan_Milestone_UpdateStatusOnNotCompleted</fullName>
        <actions>
            <name>ESN_FU006_ChangeStatusToOpen</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ESNStream__c.ESN_Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>ESNStream__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone</value>
        </criteriaItems>
        <description>(Consistency WKF): Changes the Project Plan Status to In Progress when the Milestone is unchecked as Completed = False</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ESN_WKF004_ProjectPlan_Milestone_CopyDeadlineIntoDate</fullName>
        <actions>
            <name>ESN_FU007_PlannedDeadlineToStartDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ESN_FU008_PlannedDeadlineToEndDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ESN_FU009_ActualDeadlineToStartDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ESN_FU010_ActualDeadlineToEndDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>(Consistency WKF): Update the Project Plan Actual and Planned Start and End Date with the Project Plan Deadline Date.</description>
        <formula>AND(OR( ISNEW() , NOT ( RecordType.Name =&quot;Stream&quot;), ISCHANGED( ESN_ActualDeadline__c )), NOT( ISBLANK( ESN_PlannedDeadline__c ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ESN_WKF005_ProjectPlan_CopyPlannedDateIntoActualDate</fullName>
        <actions>
            <name>ESN_FU011_ActualDeadLineEqualsPlanned</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ESN_FU012_ActualStartDateEqualsPlanned</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ESN_FU013_ActualEndDateEqualsPlanned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The Stream Actual Start and End Date &amp; Milestone Actual Deadline are updated with the values from Stream Planned Start and End Date, &amp; Milestone Planned Deadline if empty and while Status is Not Started. If PPL has started then the VR forbids the change.</description>
        <formula>OR(ISNEW(), ISCHANGED( StartDate__c ) , ISCHANGED( EndDate__c ), ISCHANGED( ESN_PlannedDeadline__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>First Email Stream</fullName>
        <active>true</active>
        <criteriaItems>
            <field>ESNStream__c.Status__c</field>
            <operation>equals</operation>
            <value>Inactive</value>
        </criteriaItems>
        <description>Email sent 3 days before the stream start date</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_3_days_before_the_stream_start_date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ESNStream__c.STR_Workflow_Start_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Second Email Stream</fullName>
        <active>true</active>
        <criteriaItems>
            <field>ESNStream__c.StartDate__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>ESNStream__c.Status__c</field>
            <operation>equals</operation>
            <value>Inactive</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_1_day_after_the_stream_start_date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ESNStream__c.STR_Workflow_After_Start_Date_1D__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Stream email</fullName>
        <actions>
            <name>UpdateContributor1EmailStream</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateContributor2EmailStream</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateProjectManagerEmailStream</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateSponsorEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateStreamLeaderEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ESNStream__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Third Email Stream</fullName>
        <active>true</active>
        <criteriaItems>
            <field>ESNStream__c.EndDate__c</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>ESNStream__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_1_day_after_the_stream_end_date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ESNStream__c.STR_Workflow_After_End_Date_1D__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>

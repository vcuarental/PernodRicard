<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ESN_FU003_ActualStartDateEqualsPlanned</fullName>
        <description>The Project Actual Start Date is updated with the values entered in Project Planned Start Date.</description>
        <field>ESN_ActualStartDate__c</field>
        <formula>StartDate__c</formula>
        <name>ESN_FU003_ActualStartDateEqualsPlanned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESN_FU004_ActualEndDateEqualsPlanned</fullName>
        <description>The Project Actual End Date is updated with the values entered in Project Planned End Date.</description>
        <field>EndDate__c</field>
        <formula>EndDate__c</formula>
        <name>ESN_FU004_ActualEndDateEqualsPlanned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContributor1Email</fullName>
        <field>Contributor1Email__c</field>
        <formula>Contributor_1__r.Email</formula>
        <name>Update contributor # 1  email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContributor2Email</fullName>
        <field>Contributor2Email__c</field>
        <formula>Contributor_2__r.Email</formula>
        <name>Update contributor # 2  email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateProjectManagerEmail</fullName>
        <field>ProjectManagerEmail__c</field>
        <formula>ProjectManager__r.Email</formula>
        <name>Update project manager email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateSponsorEmail</fullName>
        <field>SponsorEmail__c</field>
        <formula>Sponsor__r.Email</formula>
        <name>Update sponsor email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ESN_WKF001_Project_CopyPlannedDateIntoActualDate</fullName>
        <actions>
            <name>ESN_FU003_ActualStartDateEqualsPlanned</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ESN_FU004_ActualEndDateEqualsPlanned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The Project Actual Start Date and Actual End are updated with the values entered in Project Planned Start Date and Project Planned End Date while Status is Not Started. If Project has started then the Validation Rule forbids the change.</description>
        <formula>OR(ISNEW(), ISCHANGED( StartDate__c ) , ISCHANGED( EndDate__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project contributor %23 1 email</fullName>
        <actions>
            <name>UpdateContributor1Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ESNProject__c.Contributor_1__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project contributor %23 2 email</fullName>
        <actions>
            <name>UpdateContributor2Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ESNProject__c.Contributor_2__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project project manager email</fullName>
        <actions>
            <name>UpdateProjectManagerEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ESNProject__c.ProjectManager__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project sponsor email</fullName>
        <actions>
            <name>UpdateSponsorEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ESNProject__c.Sponsor__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

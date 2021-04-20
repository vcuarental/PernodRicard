<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>RIC_Notif_RCTA_Article</fullName>
        <description>RIC_Notif_RCTA_Article</description>
        <protected>false</protected>
        <recipients>
            <recipient>RIC_DAF</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>RIC_RCTA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RIC_Workflow_OPP/RIC_Article_CreationPartielle</template>
    </alerts>
    <fieldUpdates>
        <fullName>RIC_Statut_CreationPartielle</fullName>
        <description>Statut = A créer partiellement</description>
        <field>RIC_Statut__c</field>
        <literalValue>A créer partiellement</literalValue>
        <name>RIC_Statut_CreationPartielle</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Update_Editable_Checkbox</fullName>
        <field>RIC_Editable__c</field>
        <literalValue>0</literalValue>
        <name>RIC_Update_Editable_Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>RIC_ArticleKITOPP_CreationPartielle</fullName>
        <actions>
            <name>RIC_Notif_RCTA_Article</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>RIC_Statut_CreationPartielle</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Bascule le Statut à création partielle lorsque les champs nécessaires sont remplis</description>
        <formula>NOT($User.BypassWF__c) &amp;&amp; (LEFT(RecordType.DeveloperName,7)=&quot;RIC_Kit&quot;) &amp;&amp; ISPICKVAL(RIC_Statut__c,&quot;A finaliser&quot;) &amp;&amp; NOT(ISBLANK(RIC_Code_Article__c)) &amp;&amp; NOT(ISBLANK(RIC_Description_2__c)) &amp;&amp; NOT(ISBLANK(RIC_Texte_recherche__c)) &amp;&amp; NOT(ISBLANK(RIC_Brand__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RIC_ArticleMPC_CreationPartielle</fullName>
        <actions>
            <name>RIC_Notif_RCTA_Article</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>RIC_Statut_CreationPartielle</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Bascule le Statut à création partielle lorsque les champs nécessaires sont remplis.
Pour les MPC.</description>
        <formula>NOT($User.BypassWF__c) &amp;&amp; RecordType.DeveloperName=&quot;RIC_MPC&quot; &amp;&amp; ISPICKVAL(RIC_Statut__c,&quot;A finaliser&quot;) &amp;&amp; NOT(ISBLANK(RIC_Code_Article__c)) &amp;&amp; NOT(ISBLANK(RIC_Description_2__c)) &amp;&amp; NOT(ISBLANK(RIC_Texte_recherche__c)) &amp;&amp; NOT(ISBLANK(RIC_Delai_niveau__c)) &amp;&amp; NOT(ISBLANK(RIC_Magasin_usine__c)) &amp;&amp; NOT(ISBLANK(RIC_Num_fournisseur__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RIC_ArticleOPP_CreationPartielle</fullName>
        <actions>
            <name>RIC_Notif_RCTA_Article</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>RIC_Statut_CreationPartielle</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Bascule le Statut à création partielle lorsque les champs nécessaires sont remplis.
Pour les OPP.</description>
        <formula>NOT($User.BypassWF__c) &amp;&amp; (LEFT(RecordType.DeveloperName,7)=&quot;RIC_OPP&quot;) &amp;&amp; ISPICKVAL(RIC_Statut__c,&quot;A finaliser&quot;) &amp;&amp; NOT(ISBLANK(RIC_Code_Article__c)) &amp;&amp; NOT(ISBLANK(RIC_Description_2__c)) &amp;&amp; NOT(ISBLANK(RIC_Texte_recherche__c)) &amp;&amp; NOT(ISBLANK(RIC_Brand__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RIC_ArticlePF_CreationPartielle</fullName>
        <actions>
            <name>RIC_Notif_RCTA_Article</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>RIC_Statut_CreationPartielle</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow OPP &amp; Produits Finis
Bascule le Statut à création partielle lorsque les champs nécessaires sont remplis</description>
        <formula>NOT($User.BypassWF__c) &amp;&amp; CONTAINS(RecordType.DeveloperName,&quot;RIC_Produit_Fini&quot;) &amp;&amp; ISPICKVAL(RIC_Statut__c,&quot;A finaliser&quot;) &amp;&amp; NOT(ISBLANK(RIC_Code_Article__c)) &amp;&amp; NOT(ISBLANK(RIC_Description_2__c)) &amp;&amp; NOT(ISBLANK(RIC_Texte_recherche__c)) &amp;&amp; NOT(ISPICKVAL(RIC_Type_de_Protection__c,&quot;&quot;)) &amp;&amp; NOT(ISBLANK(RIC_Brand__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RIC_Update_Editable_Checkbox</fullName>
        <actions>
            <name>RIC_Update_Editable_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RIC_Article__c.RIC_Statut__c</field>
            <operation>equals</operation>
            <value>Créé</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWF__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Workflow rule to update a hidden checkbox to decide whether an Article is editable.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

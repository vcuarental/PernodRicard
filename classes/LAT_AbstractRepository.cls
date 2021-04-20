/**
 * Provide Base Repository Implementations
 * @author ercarval - topi
 */
public abstract class LAT_AbstractRepository {

    virtual
    public SObject save (SObject aggregate) {

        if (aggregate == null) return null;

        if (aggregate.Id == null ) {
            insert aggregate;
        } else {
            update aggregate;
        }

        return aggregate;
    }
 
    virtual
    public List<SObject> save (List<SObject> aggregates) {

        if (aggregates == null) return new List<SObject>();

        if (aggregates.isEmpty()) return aggregates;

        List<SObject> aggregatesToCreate = filterWithOutId (aggregates);

        if (!aggregatesToCreate.isEmpty()) {
            insert aggregatesToCreate;
        }

        List<SObject> aggregatesToUpdate = filterWithId (aggregates);

        if (!aggregatesToUpdate.isEmpty()) {
            update aggregatesToUpdate;
        }

        return aggregates;

    }

    virtual
    protected List<SObject> filterWithId (List<SObject> aggregates) {

        List<SObject> aggregatesToStore = new  List<SObject>();

        for (SObject aggregate : aggregates) {
            if (aggregate.id != null) aggregatesToStore.add (aggregate);
        }

        return aggregatesToStore;
    }

    virtual
    protected List<SObject> filterWithOutId (List<SObject> aggregates) {
        List<SObject> aggregatesToStore = new  List<SObject>();

        for (SObject aggregate : aggregates) {
            if (aggregate.id == null) aggregatesToStore.add (aggregate);
        }

        return aggregatesToStore;
    }

    virtual
    public List<Database.SaveResult> updateAll ( List<SObject> aggregates ) {

        if (aggregates == null || aggregates.isEmpty()) return new List<Database.SaveResult>();

        return Database.update (aggregates, false);
    }

    virtual
    public List<Database.SaveResult> insertAll ( List<SObject> aggregates ) {

        if (aggregates == null || aggregates.isEmpty()) return new List<Database.SaveResult>();

        return Database.insert (aggregates, false);
    }
}
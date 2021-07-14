const express = require('express');
const app = express();
const MongoClient = require('mongodb').MongoClient;
const ObjectId = require('mongodb').ObjectID;

app.use(express.json());

MongoClient.connect('mongodb+srv://baluser:balpass@cluster0.knyif.mongodb.net/myFirstDatabase?retryWrites=true&w=majority', 
{useUnifiedTopology: true}, (error, client) => {
    if (error) throw error;
    console.log('Database Connected');
    const task003Database = client.db('TASK003');
    const collectionsDatabse = task003Database.collection('CONTACTSDB');

    //Get Data
    app.get('/data', (req, res) => {
        collectionsDatabse.find({}).toArray((error, result) => {
            if (error) throw error;
            res.send(result);
        });
    });
    //Get by ID
    app.get("/personnel/:id", (request, response) => {
        collection.findOne({ "_id": new ObjectId(request.params.id) }, (error, result) => {
            if(error) {
                return response.status(500).send(error);
            }
            response.send(result);
        });
    });

    //Post Data
    app.post('/data', (req, res) => {
        const contact = {
            last_name: req.body.last_name,
            first_name: req.body.first_name,
            phone_numbers: req.body.phone_numbers
        };
        collectionsDatabse.insertOne(contact);
        res.send(contact);
    });
    
    //Get total numeber of Documents
    app.get('/data/total', (req, res) => {
        collectionsDatabse.countDocuments({}, (error, result) => {
            if(error) res.send(error);
            else res.json(result);
        })
    });

    //Delete a document by id
    app.delete('/data/:_id', (req, res) => {
        collectionsDatabse.deleteOne({_id: new ObjectId(req.params['_id'])}, (error) => {
            if (error) throw error;
        })
    });

    // Update the data by id
    app.put('/data/:_id', (req, res) => {
        const contact = {
            last_name: req.body.last_name,
            first_name: req.body.first_name,
            phone_numbers: req.body.phone_numbers
        };
        collectionsDatabse.updateOne({_id: new ObjectId(req.params['_id'])}, {$set: contact}, (error) => {
            if(error) throw error;
            else res.json(contact);
        })
    });
});

//For checking if the API is connected to postman
app.get('/', (req, res) => {
    res.send('Hello World');
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Listening on port ${port}`));
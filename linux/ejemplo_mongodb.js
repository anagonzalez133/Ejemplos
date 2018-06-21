# https://blog.knoldus.com/2018/05/02/getting-started-with-mongodb/
# https://blog.knoldus.com/2018/05/07/mongodb-2-curd/
# https://dzone.com/articles/getting-started-with-mongodb-3?utm_medium=feed&utm_source=feedpress.me&utm_campaign=Feed:%20dzone

# Comparación RDBMS - MongoDB
# Database - Database
# Table - Collection
# Row - Document
# Column - Field

# _id reservado para primary key

# Mostrar BBDDs, crear una nueva y comprobar a qué BBDD nos hemos conectado
show dbs;
use DATABASE_NAME
db

# Crear una colección, y obtener lista de colecciones:
db.createCollection("collection_name")
# { "ok" : 1 }
db.getCollectionNames();
# [ "collection_name" ]

# Insertar un documento en la colección students:
db.students.insertOne({
	"name" : "shubham",
	"age" : "12",
	"address" : "Noida"
	});
# {
#	"acknowledged": true,
#	"insertedId" : ObjectId("5aec446287bfd96214708d786")
# }

# Insertar más de uno:
db.students.insertMany([{
	"name" : "rahul",
	"age" : "15",
	"address" : "Noida"
	},
	{
	"name" : "karan",
		"age" : "20",
		"address" : "Delhi"
	}])
# {
#	"acknowledged": true,
#	"insertedIds" : [
#		ObjectId("5aec446287bfd96214708d787"),
#		ObjectId("5aec446287bfd96214708d788")
#		]
# }

# Consultar los documentos que cumplen una condición:
db.students.find({
	"name" : "shubham"
});
# { "_id" : ObjectId("5aec446287bfd96214708d786"), "name" : "shubham", "age" : "12", "address" : "Noida" }
db.COLLECTION_NAME.findOne() # Para devolver sólo el primero que encuentre que cumpla la condición

# Actualizar documentos:
db.students.update(
	{"address" : "Noida"},
	{ $set : {"age" : "21"}},
	{ multi : true } # Condición muy importante, por defecto sin esta condición sólo actualiza el primero que encuentra
)
# WriteResult({ "nMatched" : 2, "nUpserted" : 0, "nModified" : 2 })

# Borrar un documento, sin condición, borra todos los de la colección:
db.students.remove({
	"name" : "rahul"
})
# WriteResult({ "nRemoved" : 1 })

# Operadores de comparación
db.students.find({ "age" : { $eq: 24 } })
db.students.find( { "age" : { $nin :[18,24] } });
db.students.find( { $and : [
	{"name" : "Rahul"},
	{"age" : 20 }
... ]})
# = $eq
# > $gt
# >= $gte
# < $lt
# <= $lte
# != $ne
# IN $in { field: { $in: [, , ...]} }
# NOT IN $nin
# AND $and { $and: [ {}, {}, ...] }
# OR $or
# $not: Documentos que no cumplen la condición:
db.students.find( { age: { $not: { $gt: 20 } } } )
# $nor: Documentos que no cumplen ninguna de las condiciones listadas
db.students.find( { $nor: [ { "name": "Shubham" }, { "age": 20 } ] } );
# $exists: Documentos que contienen el campo (columna) aunque éste sea nulo
db.students.find({"address" : { $exists: true}});

# projection: filtrar los datos recibidos, que sólo muestre determinados campos, no todos.
# Eliminar la columna _id de la lista de resultados:
db.students.find({age:20}, {"_id" : 0})
# { "name" : "Rahul", "age" : 20, "address" : "Noida" }
# { "name" : "Aman", "age" : 20, "address" : "Noida" }

# Mostrar sólo la columna nombre
db.students.find({age:20}, {_id : 0, name : 1})

# Limitar resultados con el método cursor.limit() o bien borrar los primeros resultados con el método cursor.skip()
db.students.find().limit(2)
db.students.find().skip(2)

# Ordenar con el método sort(), en forma ascendente, 1, descendente -1
db.students.find().sort({"age":1, address : -1})



import 'package:flutter/material.dart';
import 'package:sqlite_workshop/models/db_provider.dart';
import 'package:sqlite_workshop/models/product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SQL Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _refresh = GlobalKey<RefreshIndicatorState>();
  DBProvider dbProvider;

  @override
  void initState() {
    dbProvider = DBProvider();
    super.initState();
  }

  @override
  void dispose() {
    dbProvider.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: _buuildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          createDialog();
        },
      ),
    );
  }

  AppBar buildAppBar() => AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              //delete all
              _refresh.currentState.show();
              dbProvider.deleteAllProduct();
            },
          )
        ],
      );

  buildContent() => RefreshIndicator(
        key: _refresh,
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2));
          setState(() {});
        },
        child: FutureBuilder(
          future: dbProvider.getProducts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            if (snapshot.hasData) {
              List<Product> products = snapshot.data;
              if (products.length > 0) {
                return buildListView(products.reversed.toList());
              }
              return Center(
                child: Text('NO DATA'),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );

  ListView buildListView(List<Product> product) => ListView.separated(
        itemBuilder: (context, index) {
          Product item = product[index];
          return ListTile(
            title: Text('${item.name} (${item.stock})'),
            leading: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // edit
                editDialog(item);
              },
            ),
            subtitle: Text('Price: ${item.price}'),
            trailing: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () async {
                // delete
                _refresh.currentState.show();
                dbProvider.deleteProduct(item.id);
                await Future.delayed(Duration(seconds: 2));
                
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Item deleted'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      _refresh.currentState.show();
                      dbProvider.insertProduct(item).then((value) {
                        print(product);
                      });
                    },
                  ),
                ));
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: product.length,
      );

  FutureBuilder<bool> _buuildBody() => FutureBuilder(
        future: dbProvider.initDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildContent();
          }
          return Center(
            child: snapshot.hasError
                ? Text(snapshot.error).toString()
                : CircularProgressIndicator(),
          );
        },
      );

  void createDialog() {
    var _formKey = GlobalKey<FormState>();
    Product product = Product();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'name',
                  ),
                  onSaved: (newValue) {
                    product.name = newValue;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'price',
                  ),
                  onSaved: (newValue) {
                    product.price = double.parse(newValue);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'stock',
                  ),
                  onSaved: (newValue) {
                    product.stock = int.parse(newValue);
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        _refresh.currentState.show();
                        Navigator.pop(context);
                        dbProvider.insertProduct(product).then((value) {
                          print(product);
                        });
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void editDialog(Product product) {
    var _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: product.name,
                  decoration: InputDecoration(
                    hintText: 'name',
                  ),
                  onSaved: (newValue) {
                    product.name = newValue;
                  },
                ),
                TextFormField(
                  initialValue: product.price.toString(),
                  decoration: InputDecoration(
                    hintText: 'price',
                  ),
                  onSaved: (newValue) {
                    product.price = double.parse(newValue);
                  },
                ),
                TextFormField(
                  initialValue: product.stock.toString(),
                  decoration: InputDecoration(
                    hintText: 'stock',
                  ),
                  onSaved: (newValue) {
                    product.stock = int.parse(newValue);
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        _refresh.currentState.show();
                        Navigator.pop(context);
                        dbProvider.updateProduct(product).then((value) {
                          print(value);
                        });
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

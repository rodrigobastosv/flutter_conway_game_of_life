import 'dart:math';

import 'package:flutter/material.dart';

final int rows = 700;
final int columns = 20;
final initialRate = 0.2;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conway Game of Life',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ConwayGameOfLife(),
    );
  }
}

class ConwayGameOfLife extends StatefulWidget {
  @override
  _ConwayGameOfLifeState createState() => _ConwayGameOfLifeState();
}

class _ConwayGameOfLifeState extends State<ConwayGameOfLife> {
  int generation = 0;

  void onUpdateGeneration() {
    setState(() {
      generation++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conway Game of Life'),
        centerTitle: true,
        leading: Center(
          child: Text(
            generation.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Board(onUpdateGeneration),
    );
  }
}

class Board extends StatefulWidget {
  Board(this.onUpdate);

  final VoidCallback onUpdate;

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  bool gameStarted;

  int get total => rows * columns;

  List<List<bool>> generationMatrix = [];

  void _initGame() {
    generationMatrix = [];
    for (int i = 0; i < rows; i++) {
      List<bool> row = [];
      for (int n = 0; n < columns; n++) {
        row.add(Random().nextDouble() < initialRate);
      }
      generationMatrix.add(row);
    }
  }

  @override
  void initState() {
    gameStarted = false;
    _initGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: gameStarted
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
              ),
              itemBuilder: (_, i) {
                int row = i ~/ columns;
                int column = i % columns;
                return AnimatedContainer(
                  color:
                      generationMatrix[row][column] ? Colors.green : Colors.red,
                  duration: Duration(milliseconds: 500),
                );
              },
              itemCount: total,
            )
          : Center(
              child: RaisedButton(
                child: Text('Start Game'),
                onPressed: () async {
                  setState(() {
                    gameStarted = true;
                  });
                  while (true) {
                    generationMatrix = _calculateNextGeneration();
                    await Future.delayed(Duration(seconds: 2));
                    setState(() {});
                  }
                },
              ),
            ),
    );
  }

  List<List<bool>> _calculateNextGeneration() {
    widget.onUpdate();
    List<List<bool>> nextGenerationMatrix = [];
    for (int i = 0; i < rows; i++) {
      List<bool> row = [];
      for (int n = 0; n < columns; n++) {
        row.add(false);
      }
      nextGenerationMatrix.add(row);
    }

    for (int i = 0; i < total; i++) {
      int row = i ~/ columns;
      int column = i % columns;

      if (row == 0) {
        if (column == 0) {
          nextGenerationMatrix[row][column] =
              calculateTopLeftCell(generationMatrix);
        } else if (column == columns - 1) {
          nextGenerationMatrix[row][column] =
              calculateTopRightCell(generationMatrix);
        } else {
          nextGenerationMatrix[row][column] =
              calculateFirstRow(column, generationMatrix);
        }
      } else if (row == rows - 1) {
        if (column == 0) {
          nextGenerationMatrix[row][column] =
              calculateBotLeftCell(generationMatrix);
        } else if (column == columns - 1) {
          nextGenerationMatrix[row][column] =
              calculateBotRightCell(generationMatrix);
        } else {
          nextGenerationMatrix[row][column] =
              calculateLastRow(column, generationMatrix);
        }
      } else if (column == 0) {
        nextGenerationMatrix[row][column] =
            calculateFirstColumn(row, generationMatrix);
      } else if (column == columns - 1) {
        nextGenerationMatrix[row][column] =
            calculateLastColumn(row, generationMatrix);
      } else {
        nextGenerationMatrix[row][column] =
            calculateCellState(row, column, generationMatrix);
      }
    }

    return nextGenerationMatrix;
  }

  bool calculateTopLeftCell(List<List<bool>> matrix) {
    int numberOfLivingNeighbors = 0;

    if (matrix[0][1]) numberOfLivingNeighbors++;
    if (matrix[1][0]) numberOfLivingNeighbors++;
    if (matrix[1][1]) numberOfLivingNeighbors++;

    return driveToRules(
      isAlive: matrix[0][0],
      numberOfLivingNeighbors: numberOfLivingNeighbors,
    );
  }

  bool calculateTopRightCell(List<List<bool>> matrix) {
    int numberOfLivingNeighbors = 0;

    if (matrix[0][columns - 2]) numberOfLivingNeighbors++;
    if (matrix[1][columns - 2]) numberOfLivingNeighbors++;
    if (matrix[1][columns - 1]) numberOfLivingNeighbors++;

    return driveToRules(
      isAlive: matrix[0][columns - 1],
      numberOfLivingNeighbors: numberOfLivingNeighbors,
    );
  }

  bool calculateBotLeftCell(List<List<bool>> matrix) {
    int numberOfLivingNeighbors = 0;

    if (matrix[rows - 2][0]) numberOfLivingNeighbors++;
    if (matrix[rows - 2][1]) numberOfLivingNeighbors++;
    if (matrix[rows - 1][1]) numberOfLivingNeighbors++;

    return driveToRules(
      isAlive: matrix[rows - 1][0],
      numberOfLivingNeighbors: numberOfLivingNeighbors,
    );
  }

  bool calculateBotRightCell(List<List<bool>> matrix) {
    int numberOfLivingNeighbors = 0;

    if (matrix[rows - 2][columns - 2]) numberOfLivingNeighbors++;
    if (matrix[rows - 2][columns - 1]) numberOfLivingNeighbors++;
    if (matrix[rows - 1][columns - 2]) numberOfLivingNeighbors++;

    return driveToRules(
      isAlive: matrix[rows - 1][columns - 1],
      numberOfLivingNeighbors: numberOfLivingNeighbors,
    );
  }

  bool calculateFirstRow(int c, List<List<bool>> matrix) {
    int numberOfLivingNeighbors = 0;

    if (matrix[0][c - 1]) numberOfLivingNeighbors++;
    if (matrix[0][c + 1]) numberOfLivingNeighbors++;

    if (matrix[1][c - 1]) numberOfLivingNeighbors++;
    if (matrix[1][c]) numberOfLivingNeighbors++;
    if (matrix[1][c + 1]) numberOfLivingNeighbors++;

    return driveToRules(
      isAlive: matrix[0][c],
      numberOfLivingNeighbors: numberOfLivingNeighbors,
    );
  }

  bool calculateLastRow(int c, List<List<bool>> matrix) {
    int numberOfLivingNeighbors = 0;

    if (matrix[rows - 1][c - 1]) numberOfLivingNeighbors++;
    if (matrix[rows - 1][c + 1]) numberOfLivingNeighbors++;
    if (matrix[rows - 2][c - 1]) numberOfLivingNeighbors++;
    if (matrix[rows - 2][c]) numberOfLivingNeighbors++;
    if (matrix[rows - 2][c + 1]) numberOfLivingNeighbors++;

    return driveToRules(
      isAlive: matrix[rows - 1][c],
      numberOfLivingNeighbors: numberOfLivingNeighbors,
    );
  }

  bool calculateFirstColumn(int r, List<List<bool>> matrix) {
    int numberOfLivingNeighbors = 0;

    if (matrix[r - 1][0]) numberOfLivingNeighbors++;
    if (matrix[r - 1][1]) numberOfLivingNeighbors++;
    if (matrix[r][1]) numberOfLivingNeighbors++;
    if (matrix[r + 1][0]) numberOfLivingNeighbors++;
    if (matrix[r + 1][1]) numberOfLivingNeighbors++;

    return driveToRules(
      isAlive: matrix[r][0],
      numberOfLivingNeighbors: numberOfLivingNeighbors,
    );
  }

  bool calculateLastColumn(int r, List<List<bool>> matrix) {
    int numberOfLivingNeighbors = 0;

    if (matrix[r - 1][columns - 2]) numberOfLivingNeighbors++;
    if (matrix[r - 1][columns - 1]) numberOfLivingNeighbors++;
    if (matrix[r][columns - 2]) numberOfLivingNeighbors++;
    if (matrix[r + 1][columns - 2]) numberOfLivingNeighbors++;
    if (matrix[r + 1][columns - 1]) numberOfLivingNeighbors++;

    return driveToRules(
      isAlive: matrix[r][columns - 1],
      numberOfLivingNeighbors: numberOfLivingNeighbors,
    );
  }

  bool calculateCellState(int r, int c, List<List<bool>> matrix) {
    int numberOfLivingNeighbors = 0;

    if (matrix[r - 1][c - 1]) numberOfLivingNeighbors++;
    if (matrix[r - 1][c]) numberOfLivingNeighbors++;
    if (matrix[r - 1][c + 1]) numberOfLivingNeighbors++;
    if (matrix[r][c - 1]) numberOfLivingNeighbors++;
    if (matrix[r][c + 1]) numberOfLivingNeighbors++;
    if (matrix[r + 1][c - 1]) numberOfLivingNeighbors++;
    if (matrix[r + 1][c]) numberOfLivingNeighbors++;
    if (matrix[r + 1][c + 1]) numberOfLivingNeighbors++;

    return driveToRules(
      isAlive: matrix[r][c],
      numberOfLivingNeighbors: numberOfLivingNeighbors,
    );
  }

  bool driveToRules({bool isAlive, numberOfLivingNeighbors}) {
    if (isAlive &&
        (numberOfLivingNeighbors == 2 || numberOfLivingNeighbors == 3)) {
      return true;
    }
    if (!isAlive && numberOfLivingNeighbors == 3) {
      return true;
    }
    return false;
  }
}

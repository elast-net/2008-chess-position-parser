## Chess Position Parser (Perl, 2008)
Written for my Master's thesis on artificial neural networks. 
Parses chess game records (PGN format) and reconstructs the full 
board state move-by-move — handling ambiguous piece moves, castling, 
en passant, and pawn promotion — to generate training data for a 
neural network (JavaNNS) predicting game outcomes.

Note: written as a research/data-preparation script, not 
production code — prioritized correctness of chess-move parsing 
over code structure.

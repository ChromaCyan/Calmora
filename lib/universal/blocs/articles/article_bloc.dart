import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/services/api.dart';

// EVENT BLOC LINE HERE
//=================================================================================================
abstract class ArticleEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchRecommendedArticles extends ArticleEvent {
  final String patientId;
  FetchRecommendedArticles(this.patientId);
}

class FetchAllArticles extends ArticleEvent {}

class FetchArticlesBySpecialist extends ArticleEvent {
  final String specialistId;
  FetchArticlesBySpecialist(this.specialistId);
}

class FetchArticleById extends ArticleEvent {
  final String articleId;
  FetchArticleById(this.articleId);
}

class CreateArticle extends ArticleEvent {
  final Article article;
  CreateArticle(this.article);
}

class UpdateArticle extends ArticleEvent {
  final String articleId;
  final String? title;
  final String? content;
  final String? heroImage;
  final List<String>? additionalImages;
  final List<String>? categories;
  final String? targetGender;
  UpdateArticle({
    required this.articleId,
    this.title,
    this.content,
    this.heroImage,
    this.additionalImages,
    this.categories,
    this.targetGender,
  });
}

class DeleteArticle extends ArticleEvent {
  final String articleId;
  final String specialistId;

  DeleteArticle(this.articleId, this.specialistId);
}
//=================================================================================================
// STATE BLOC LINE HERE
abstract class ArticleState extends Equatable {
  @override
  List<Object> get props => [];
}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;
  ArticleLoaded(this.articles);
}

class ArticleDetailLoaded extends ArticleState {
  final Article article;
  ArticleDetailLoaded(this.article);
}

class ArticleError extends ArticleState {
  final String message;
  ArticleError(this.message);
}

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ApiRepository _apiRepository;
  
  ArticleBloc({required ApiRepository apiRepository})
      : _apiRepository = apiRepository,
        super(ArticleInitial()) {
    on<FetchRecommendedArticles>(_onFetchRecommendedArticles);
    on<FetchAllArticles>(_onFetchAllArticles);
    on<FetchArticlesBySpecialist>(_onFetchArticlesBySpecialist);
    on<FetchArticleById>(_onFetchArticleById);
    on<CreateArticle>(_onCreateArticle);
    on<UpdateArticle>(_onUpdateArticle); 
    on<DeleteArticle>(_onDeleteArticle);
  }

  // Fetch recommended articles for the patient
  Future<void> _onFetchRecommendedArticles(
      FetchRecommendedArticles event, Emitter<ArticleState> emit) async {
    emit(ArticleLoading());
    print("🟠 Fetching articles for Patient ID: ${event.patientId}");

    try {
      final articles = await _apiRepository.getRecommendedArticles(event.patientId);
      print("🟢 Articles fetched: ${articles.length}");
      emit(ArticleLoaded(articles));
    } catch (e) {
      print("🔴 Error fetching articles: $e");
      emit(ArticleError(e.toString()));
    }
  }

  // Fetch all articles
  Future<void> _onFetchAllArticles(
      FetchAllArticles event, Emitter<ArticleState> emit) async {
    emit(ArticleLoading());
    try {
      final articles = await _apiRepository.getAllArticles();
      emit(ArticleLoaded(articles));
    } catch (e) {
      emit(ArticleError(e.toString()));
    }
  }

  // Fetch articles by specialist
  Future<void> _onFetchArticlesBySpecialist(
      FetchArticlesBySpecialist event, Emitter<ArticleState> emit) async {
    emit(ArticleLoading());
    try {
      final articles = await _apiRepository.getArticlesBySpecialist(event.specialistId);
      emit(ArticleLoaded(articles));
    } catch (e) {
      emit(ArticleError(e.toString()));
    }
  }

  // Fetch a specific article by ID
  Future<void> _onFetchArticleById(
      FetchArticleById event, Emitter<ArticleState> emit) async {
    emit(ArticleLoading());
    try {
      final article = await _apiRepository.getArticleById(event.articleId);
      emit(ArticleDetailLoaded(article));
    } catch (e) {
      emit(ArticleError(e.toString()));
    }
  }

  // Create a new article
  Future<void> _onCreateArticle(
      CreateArticle event, Emitter<ArticleState> emit) async {
    try {
      await _apiRepository.createArticle(
        title: event.article.title,
        content: event.article.content,
        heroImage: event.article.heroImage,
        specialistId: event.article.specialistId,
        categories: event.article.categories,
        targetGender: event.article.targetGender,
      );
      add(FetchAllArticles());
    } catch (e) {
      emit(ArticleError(e.toString()));
    }
  }

  // Update an existing article
  Future<void> _onUpdateArticle(
      UpdateArticle event, Emitter<ArticleState> emit) async {
    try {
      await _apiRepository.updateArticle(
        articleId: event.articleId,
        title: event.title,
        content: event.content,
        heroImage: event.heroImage,
        additionalImages: event.additionalImages,
        categories: event.categories,
        targetGender: event.targetGender,
      );
      add(FetchArticleById(event.articleId));
    } catch (e) {
      emit(ArticleError(e.toString()));
    }
  }

  // Delete an article
  Future<void> _onDeleteArticle(
      DeleteArticle event, Emitter<ArticleState> emit) async {
    try {
      await _apiRepository.deleteArticle(event.articleId);
      add(FetchArticlesBySpecialist(event.specialistId));
    } catch (e) {
      emit(ArticleError(e.toString()));
    }
  }
}

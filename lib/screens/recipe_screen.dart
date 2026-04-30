import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/daily_record.dart';
import '../models/diet_plan.dart';
import '../providers/api_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<Recipe> _savedRecipes = [];
  DietPlan? _todayDiet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final record = await StorageService.getRecord(dateStr);
    final recipes = await StorageService.getAllRecipes();
    setState(() {
      _todayDiet = record?.dietPlan;
      _savedRecipes = recipes;
      _isLoading = false;
    });
  }

  Future<void> _generateRecipe(String dishName, String mealType) async {
    final apiProvider = context.read<ApiProvider>();
    if (apiProvider.planGenerator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('请先配置 API'), backgroundColor: AppColors.primaryDark),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('正在生成菜谱...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final recipe = await apiProvider.planGenerator!.generateRecipe(dishName, mealType);
      await StorageService.saveRecipe(recipe);
      if (mounted) Navigator.pop(context);
      if (mounted) _showRecipeDetail(recipe);
      _loadData();
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e'), backgroundColor: AppColors.primaryDark),
        );
      }
    }
  }

  void _showRecipeDetail(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(recipe.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Text(recipe.mealType, style: const TextStyle(fontSize: 12, color: AppColors.primaryDark)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (recipe.totalTime.isNotEmpty) ...[
                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(recipe.totalTime, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 16),
                  ],
                  if (recipe.difficulty.isNotEmpty) ...[
                    const Icon(Icons.signal_cellular_alt, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(recipe.difficulty, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              const Text('食材清单', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              ...recipe.ingredients.map((ing) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.primary)),
                    Expanded(child: Text(ing.name, style: const TextStyle(fontSize: 13, color: AppColors.textBody))),
                    Text(ing.amount, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              )),
              const SizedBox(height: 20),
              const Text('制作步骤', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              ...recipe.steps.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.5))),
                  ],
                ),
              )),
              if (recipe.tips != null && recipe.tips!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.cream.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.tips_and_updates_outlined, size: 16, color: AppColors.cream),
                      const SizedBox(width: 8),
                      Expanded(child: Text(recipe.tips!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('今日菜谱')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodayMeals(),
                    const SizedBox(height: 24),
                    _buildSavedRecipes(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTodayMeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.restaurant_rounded, size: 18, color: AppColors.mint),
            const SizedBox(width: 8),
            const Text('今日饮食', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        if (_todayDiet == null || _todayDiet!.meals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                Text('🍽️', style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text('暂无饮食计划', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
                Text('先去生成饮食计划吧~', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          )
        else
          ...(_todayDiet!.meals.map((meal) => _buildMealCard(meal))),
      ],
    );
  }

  Widget _buildMealCard(MealPlan meal) {
    final mealIcons = {'早餐': '☀️', '午餐': '🌤', '晚餐': '🌙', '加餐': '🍎'};
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(mealIcons[meal.mealType] ?? '🍽️', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.mealType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      if (meal.menu.isNotEmpty)
                        Text(meal.menu, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (meal.calories.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: Text(meal.calories, style: const TextStyle(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          if (meal.items.isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                children: meal.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Text('• ', style: TextStyle(color: AppColors.mint, fontSize: 13)),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 13, color: AppColors.textBody))),
                      GestureDetector(
                        onTap: () => _generateRecipe(item, meal.mealType),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.mint.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('看做法', style: TextStyle(fontSize: 11, color: AppColors.mint, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavedRecipes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('已保存菜谱 (${_savedRecipes.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        if (_savedRecipes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                Text('📖', style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text('还没有菜谱', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
                Text('点击今日饮食中的"看做法"生成', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          )
        else
          ..._savedRecipes.map((recipe) => _buildRecipeCard(recipe)),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () => _showRecipeDetail(recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('🍳', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(recipe.mealType, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                      if (recipe.totalTime.isNotEmpty) ...[
                        const Text(' · ', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                        Text(recipe.totalTime, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                      ],
                      if (recipe.difficulty.isNotEmpty) ...[
                        const Text(' · ', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                        Text(recipe.difficulty, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

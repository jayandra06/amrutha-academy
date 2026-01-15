import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { SearchHistory } from '@/types';

export class SearchService {
  static async getSearchSuggestions(): Promise<string[]> {
    try {
      const doc = await db.collection(COLLECTIONS.SEARCH_SUGGESTIONS).doc('default').get();
      
      if (!doc.exists) {
        return [];
      }

      return doc.data()?.suggestions || [];
    } catch (error) {
      console.error('Error fetching search suggestions:', error);
      throw error;
    }
  }

  static async getSearchHistory(userId: string): Promise<SearchHistory[]> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.SEARCH_HISTORY)
        .where('userId', '==', userId)
        .orderBy('searchedAt', 'desc')
        .limit(20)
        .get();

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          keyword: data?.keyword || '',
          searchedAt: data?.searchedAt?.toDate?.().toISOString() || data?.searchedAt || '',
        } as SearchHistory;
      });
    } catch (error) {
      console.error('Error fetching search history:', error);
      throw error;
    }
  }

  static async addSearchHistory(userId: string, keyword: string): Promise<void> {
    try {
      await db.collection(COLLECTIONS.SEARCH_HISTORY).add({
        userId,
        keyword,
        searchedAt: new Date(),
      });
    } catch (error) {
      console.error('Error adding search history:', error);
      throw error;
    }
  }
}


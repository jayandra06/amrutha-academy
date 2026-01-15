import { ApiResponse, PaginationResponse } from '@/types';

export function createSuccessResponse<T>(
  data: T,
  statusCode: number = 200,
  message?: string[]
): ApiResponse<T> {
  return {
    statusCode,
    message,
    data,
  };
}

export function createErrorResponse(
  error: string,
  statusCode: number = 400
): ApiResponse<null> {
  return {
    statusCode,
    error,
    data: null,
  };
}

export function createPaginatedResponse<T>(
  data: T[],
  page: number = 1,
  limit: number = 10,
  total?: number
): ApiResponse<T[]> {
  const totalItems = total ?? data.length;
  const totalPages = Math.ceil(totalItems / limit);
  
  const pagination: PaginationResponse = {
    page,
    limit,
    total: totalItems,
    totalPages,
  };

  return {
    statusCode: 200,
    data,
    pagination,
  };
}


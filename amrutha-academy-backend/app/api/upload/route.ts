import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { StorageService } from '@/lib/services/storageService';

export async function POST(request: NextRequest) {
  try {
    // Verify authentication
    const authHeader = request.headers.get('authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        createErrorResponse('Unauthorized', 401),
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    const user = await verifyFirebaseToken(token);

    if (!user) {
      return NextResponse.json(
        createErrorResponse('Unauthorized - Invalid token', 401),
        { status: 401 }
      );
    }

    // Get form data
    const formData = await request.formData();
    const file = formData.get('file') as File;
    const folder = formData.get('folder') as string || 'uploads';

    if (!file) {
      return NextResponse.json(
        createErrorResponse('No file provided', 400),
        { status: 400 }
      );
    }

    // Convert file to buffer
    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);

    // Generate unique file path
    const timestamp = Date.now();
    const fileName = `${folder}/${timestamp}-${file.name}`;

    // Upload to Firebase Storage
    const downloadURL = await StorageService.uploadFile(
      buffer,
      fileName,
      file.type
    );

    return NextResponse.json(
      createSuccessResponse(
        { url: downloadURL, path: fileName },
        200,
        ['File uploaded successfully']
      ),
      { status: 200 }
    );
  } catch (error) {
    console.error('Upload error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}


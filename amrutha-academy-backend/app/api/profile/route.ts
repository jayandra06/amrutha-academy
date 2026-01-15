import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { UserService } from '@/lib/services/userService';

export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        createErrorResponse('Unauthorized - No token provided', 401),
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

    return NextResponse.json(
      createSuccessResponse(user, 200),
      { status: 200 }
    );
  } catch (error) {
    console.error('Profile fetch error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}

export async function PUT(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        createErrorResponse('Unauthorized - No token provided', 401),
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

    const body = await request.json();
    const { fullName, email, bio, location, birthday, role } = body;

    const updatedUser = await UserService.updateUser(user.id, {
      fullName,
      email,
      bio,
      location,
      birthday,
      role: role || 'student',
    });

    return NextResponse.json(
      createSuccessResponse(updatedUser, 200, ['Profile updated successfully']),
      { status: 200 }
    );
  } catch (error: any) {
    console.error('Profile update error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}

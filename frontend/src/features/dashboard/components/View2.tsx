import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/components/ui/card';

export const View2 = () => {
  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-6">View 2</h1>
      <Card>
        <CardHeader>
          <CardTitle>View 2 Content</CardTitle>
          <CardDescription>This is a placeholder for View 2</CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-gray-600">Content for View 2 will be displayed here.</p>
        </CardContent>
      </Card>
    </div>
  );
};

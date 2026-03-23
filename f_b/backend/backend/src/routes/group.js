import { db } from '../db/index.js';
import { groups, groupMembers, users } from '../db/schema.js';
import { eq } from 'drizzle-orm';

async function groupRoutes(app, options) {
  // Create group
  app.post('/create', {
    onRequest: [app.authenticate]
  }, async (request, reply) => {
    try {
      console.log('Received Group Create Request:', request.body);
      const { name, description, members, imageUrl } = request.body;
      
      // Use ID from JWT if not provided in body
      const creatorId = request.body.createdBy || request.user.id;
      
      if (!creatorId) {
        throw new Error('User ID is required (token missing or invalid)');
      }

      const [newGroup] = await db.insert(groups).values({
        name,
        description,
        imageUrl,
        createdBy: creatorId
      }).returning();

      console.log('Group Created:', newGroup);

      if (members && members.length > 0) {
        const memberEntries = members.map(userId => ({
          groupId: newGroup.groupId,
          userId,
          addedBy: creatorId
        }));
        console.log('Inserting members:', memberEntries);
        await db.insert(groupMembers).values(memberEntries);
      }

      return { success: true, data: newGroup };
    } catch (error) {
      console.error('Error creating group:', error);
      request.log.error('Error creating group:', error);
      reply.status(500).send({ success: false, message: error.message });
    }
  });

  // Get all groups
  app.get('/list', {
    onRequest: [app.authenticate]
  }, async (request, reply) => {
    try {
      const allGroups = await db.select().from(groups);
      return { success: true, data: allGroups };
    } catch (error) {
      reply.status(500).send({ success: false, message: error.message });
    }
  });

  // Get group members with detailed info
  app.get('/:id/members', {
    onRequest: [app.authenticate]
  }, async (request, reply) => {
    try {
      const { id } = request.params;
      const membersData = await db.select({
        userId: users.userId,
        firstName: users.firstName,
        lastName: users.lastName,
        designation: users.designation,
        department: users.department,
        profilePhotoUrl: users.profilePhotoUrl
      })
      .from(groupMembers)
      .innerJoin(users, eq(groupMembers.userId, users.userId))
      .where(eq(groupMembers.groupId, id));
      
      return { success: true, data: membersData };
    } catch (error) {
      reply.status(500).send({ success: false, message: error.message });
    }
  });
}

export default groupRoutes;

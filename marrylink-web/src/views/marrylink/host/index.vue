<template>
  <div class="app-container">
    <!-- 搜索区域 -->
    <div class="search-container">
      <el-form :model="queryParams" :inline="true">
        <el-form-item label="关键字">
          <el-input
            v-model="queryParams.keyword"
            placeholder="主持人姓名/编号/手机号"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>

        <!-- <el-form-item label="服务地区">
          <el-input
            v-model="queryParams.serviceAreas"
            placeholder="服务地区"
            clearable
          />
        </el-form-item> -->

        <el-form-item label="状态" style="width: 150px;">
          <el-select v-model="queryParams.status" placeholder="全部" clearable >
            <el-option label="正常" :value="1" />
            <el-option label="待审核" :value="2" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" icon="search" @click="handleQuery">搜索</el-button>
          <el-button icon="refresh" @click="handleResetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-card shadow="hover">
      <div class="data-table__toolbar">
        <el-button v-if="isAdmin" type="success" icon="plus" @click="handleOpenDialog()">新增</el-button>
        <el-button v-if="isAdmin" type="primary" icon="upload" @click="handleOpenImportDialog">导入</el-button>
        <el-button v-if="isAdmin" type="info" icon="download" @click="handleDownloadTemplate">下载模板</el-button>
      </div>

      <el-table v-loading="loading" :data="pageData" border stripe>
        <el-table-column label="头像" width="80">
          <template #default="scope">
            <el-image
              v-if="scope.row.avatar"
              :src="getImageUrl(scope.row.avatar)"
              :preview-src-list="[getImageUrl(scope.row.avatar)]"
              fit="cover"
              style="width: 40px; height: 40px; border-radius: 50%;"
            />
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="姓名" prop="name" width="90" />
        <el-table-column label="艺名" prop="stageName" width="90">
          <template #default="scope">{{ scope.row.stageName || '-' }}</template>
        </el-table-column>
        <el-table-column label="性别" prop="gender" width="60">
          <template #default="scope">{{ scope.row.gender || '-' }}</template>
        </el-table-column>
        <el-table-column label="手机号" prop="phone" width="120" />
        <el-table-column label="邮箱" prop="email" width="160">
          <template #default="scope">{{ scope.row.email || '-' }}</template>
        </el-table-column>
        <el-table-column label="服务价格" prop="price" width="100">
          <template #default="scope">
            {{ scope.row.price ? '¥' + scope.row.price + '/场' : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="评分" prop="rating" width="70" />
        <el-table-column label="标签" prop="tags" width="200">
          <template #default="scope">
            <template v-if="scope.row.tags && scope.row.tags.length">
              <el-tag
                v-for="(val, idx) in scope.row.tags"
                :key="idx"
                :type="getTagType(idx)"
                effect="light"
                round
                size="small"
                class="tag-item"
              >
                {{ getTagName(val) }}
              </el-tag>
            </template>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="从业年限" width="90">
          <template #default="scope">{{ scope.row.yearsOfExperience ? scope.row.yearsOfExperience + '年' : '-' }}</template>
        </el-table-column>
        <el-table-column label="订单数" prop="orderCount" width="80" />
        <el-table-column label="状态" width="90">
          <template #default="scope">
            <el-tag v-if="scope.row.status == 1" type="success">正常</el-tag>
            <el-tag v-else-if="scope.row.status == 2" type="warning">待审核</el-tag>
            <el-tag v-else type="info">禁用</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="入驻时间" prop="joinTime" width="120" />
        <el-table-column label="操作" fixed="right" width="280">
          <template #default="scope">
            <el-button type="primary" icon="view" link size="small" @click="handleOpenAuditDetail(scope.row)">
              查看
            </el-button>
            <template v-if="scope.row.status == 2 && isAdmin">
              <el-button type="success" icon="check" link size="small" @click="handleAudit(scope.row.id, 'approve')">
                通过
              </el-button>
              <el-button type="danger" icon="close" link size="small" @click="handleAudit(scope.row.id, 'reject')">
                拒绝
              </el-button>
            </template>
            <el-button type="primary" icon="edit" link size="small" @click="handleOpenDialog(scope.row.id)">
              编辑
            </el-button>
            <el-button type="danger" icon="delete" link size="small" @click="handleDelete(scope.row.id)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-if="total > 0"
        :total="total"
        :page="queryParams.current"
        :limit="queryParams.size"
        @update:page="queryParams.current = $event"
        @update:limit="queryParams.size = $event"
        @pagination="fetchData"
      />
    </el-card>

    <!-- 表单弹窗 -->
    <el-dialog v-model="dialog.visible" :title="dialog.title" width="600px" @close="handleCloseDialog">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="主持人姓名" prop="name">
          <el-input v-model="formData.name" placeholder="请输入姓名" />
        </el-form-item>

        <el-form-item label="艺名" prop="stageName">
          <el-input v-model="formData.stageName" placeholder="请输入艺名" />
        </el-form-item>

        <el-form-item label="手机号" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入手机号" />
        </el-form-item>

        <el-form-item label="邮箱" prop="email">
          <el-input v-model="formData.email" placeholder="请输入邮箱" />
        </el-form-item>

        <el-form-item label="服务价格" prop="price">
          <el-input-number v-model="formData.price" :min="0" :precision="2" />
          <span class="ml-2">元/场</span>
        </el-form-item>

        <!-- <el-form-item label="服务地区" prop="serviceAreas">
          <el-input v-model="formData.serviceAreas" placeholder="如:北京市,上海市" />
        </el-form-item> -->

        <el-form-item label="主持人描述" prop="description">
          <el-input v-model="formData.description" placeholder="主持人描述" />
        </el-form-item>

        <el-form-item label="服务标签" prop="tags">
          <el-select
            v-model="formData.tags"
            multiple
            placeholder="请选择标签"
            style="width: 100%"
          >
            <el-option
              v-for="tag in tagDict"
              :key="tag.id"
              :label="tag.name"
              :value="tag.code"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="入驻时间" prop="joinTime">
          <el-date-picker v-model="formData.joinTime" type="date" placeholder="选择日期" value-format="YYYY-MM-DD" />
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio :label="1">正常</el-radio>
            <el-radio :label="2">待审核</el-radio>
            <el-radio :label="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="handleCloseDialog">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 导入弹窗 -->
    <el-dialog v-model="importDialog.visible" title="导入主持人" width="500px" @close="handleCloseImportDialog">
      <el-upload
        ref="uploadRef"
        class="upload-demo"
        drag
        :action="importUrl"
        :headers="uploadHeaders"
        :before-upload="beforeUpload"
        :on-success="handleImportSuccess"
        :on-error="handleImportError"
        :on-change="handleFileChange"
        :limit="1"
        accept=".xlsx,.xls"
        :auto-upload="false"
      >
        <el-icon class="el-icon--upload"><upload-filled /></el-icon>
        <div class="el-upload__text">
          将文件拖到此处，或<em>点击上传</em>
        </div>
        <template #tip>
          <div class="el-upload__tip">
            只能上传 xlsx/xls 文件，且不超过 10MB
          </div>
        </template>
      </el-upload>
      <template #footer>
        <el-button @click="handleCloseImportDialog">取消</el-button>
        <el-button type="primary" :loading="importLoading" @click="handleImportSubmit">确定导入</el-button>
      </template>
    </el-dialog>
    <!-- 主持人详情弹窗 -->
    <el-dialog v-model="auditDialog.visible" title="主持人详情" width="650px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="姓名">{{ auditDialog.data.name || '-' }}</el-descriptions-item>
        <el-descriptions-item label="艺名">{{ auditDialog.data.stageName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="性别">{{ auditDialog.data.gender || '-' }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ auditDialog.data.phone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ auditDialog.data.email || '-' }}</el-descriptions-item>
        <el-descriptions-item label="从业年限">{{ auditDialog.data.yearsOfExperience ? auditDialog.data.yearsOfExperience + '年' : '-' }}</el-descriptions-item>
        <el-descriptions-item label="服务报价">{{ auditDialog.data.price ? '¥' + auditDialog.data.price + '/场' : '-' }}</el-descriptions-item>
        <el-descriptions-item label="评分">{{ auditDialog.data.rating || '-' }}</el-descriptions-item>
        <el-descriptions-item label="服务区域">{{ formatServiceAreas(auditDialog.data.serviceAreas) }}</el-descriptions-item>
        <el-descriptions-item label="订单数">{{ auditDialog.data.orderCount ?? '-' }}</el-descriptions-item>
        <el-descriptions-item label="标签" :span="2">
          <template v-if="auditDialog.data.tags && auditDialog.data.tags.length">
            <el-tag v-for="(val, idx) in auditDialog.data.tags" :key="idx" :type="getTagType(idx)" effect="light" round size="small" style="margin-right: 6px;">
              {{ getTagName(val) }}
            </el-tag>
          </template>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag v-if="auditDialog.data.status == 1" type="success">正常</el-tag>
          <el-tag v-else-if="auditDialog.data.status == 2" type="warning">待审核</el-tag>
          <el-tag v-else type="info">禁用</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="入驻时间">{{ auditDialog.data.joinTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="个人简介" :span="2">{{ auditDialog.data.description || '-' }}</el-descriptions-item>
      </el-descriptions>

      <div class="audit-images" v-if="auditDialog.data.avatar || auditDialog.data.certificate">
        <div class="audit-image-item" v-if="auditDialog.data.avatar">
          <div class="audit-image-label">个人照片</div>
          <el-image :src="getImageUrl(auditDialog.data.avatar)" :preview-src-list="[getImageUrl(auditDialog.data.avatar)]" fit="cover" style="width: 120px; height: 120px; border-radius: 8px;" />
        </div>
        <div class="audit-image-item" v-if="auditDialog.data.certificate">
          <div class="audit-image-label">资质证明</div>
          <el-image :src="getImageUrl(auditDialog.data.certificate)" :preview-src-list="[getImageUrl(auditDialog.data.certificate)]" fit="cover" style="width: 120px; height: 120px; border-radius: 8px;" />
        </div>
      </div>

      <template #footer>
        <el-button @click="auditDialog.visible = false">关闭</el-button>
        <template v-if="auditDialog.data.status == 2 && isAdmin">
          <el-button type="danger" @click="handleAudit(auditDialog.data.id, 'reject'); auditDialog.visible = false">拒绝</el-button>
          <el-button type="success" @click="handleAudit(auditDialog.data.id, 'approve'); auditDialog.visible = false">通过</el-button>
        </template>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { UploadFilled } from '@element-plus/icons-vue'
import { getHostPage, getHostById, saveHost, updateHost, deleteHost, getTagList, importHost, downloadHostTemplate, auditHost } from '@/api/marrylink-api'
import Pagination from '@/components/Pagination/index.vue'
import { useUserStore } from '@/store/modules/user'
import { TOKEN_KEY } from '@/enums/CacheEnum'

// 构建图片URL：直接使用 /uploads/... 路径（通过vite proxy代理到后端）
function getImageUrl(path) {
  if (!path) return ''
  // 如果已经是完整URL则直接返回
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  return path
}

const queryParams = reactive({
  current: 1,
  size: 10,
  keyword: '',
  serviceAreas: '',
  status: undefined
})

const pageData = ref([])
const total = ref(0)
const loading = ref(false)

const dialog = reactive({
  visible: false,
  title: '新增主持人'
})

const formData = reactive({
  id: null,
  name: '',
  stageName: '',
  phone: '',
  email: '',
  avatar: '/uploads/avatars/defAvatar.png',
  price: 0,
  serviceAreas: '',
  tags: [],
  joinTime: '',
  status: 1
})

const formRef = ref()

const rules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ]
}
const tagDict = ref([])

// 用户角色判断
const userStore = useUserStore()
const isAdmin = computed(() => {
  // 检查用户角色是否包含ADMIN
  return userStore.user.userType.includes('ADMIN')
})

// 导入相关
const importDialog = reactive({
  visible: false
})
const uploadRef = ref()
const importLoading = ref(false)
const importUrl = '/api/v1/host/import'
const uploadHeaders = computed(() => ({
  Authorization: localStorage.getItem(TOKEN_KEY) || ''
}))
const selectedFile = ref(null)

// 审核弹窗
const auditDialog = reactive({
  visible: false,
  data: {}
})

onMounted(async () => {
  // 获取所有标签字典
  const res = await getTagList("01");
  tagDict.value = res
})

// 根据索引获取标签类型（使用 Element Plus 的预设类型）
const getTagType = (index) => {
  const types = ['primary', 'warning', 'success', 'danger'];
  return types[index % types.length];
};

const getTagName = (val) => {
  return tagDict.value.find(item => item.code === val)?.name || val;
};

async function fetchData() {
  loading.value = true
  try {
    const res = await getHostPage(queryParams)
    pageData.value = res.records
    total.value = res.total
  } finally {
    loading.value = false
  }
}

function handleQuery() {
  queryParams.current = 1
  fetchData()
}

function handleResetQuery() {
  queryParams.keyword = ''
  queryParams.serviceAreas = ''
  queryParams.status = null
  handleQuery()
}

async function handleOpenDialog(id) {
  dialog.visible = true
  if (id) {
    dialog.title = '编辑主持人'
    const res = await getHostById(id)
    Object.assign(formData, res)
  } else {
    dialog.title = '新增主持人'
  }
}

function handleCloseDialog() {
  dialog.visible = false
  formRef.value?.resetFields()
  Object.assign(formData, {
    id: null,
    name: '',
    stageName: '',
    phone: '',
    email: '',
    avatar: '/uploads/avatars/defAvatar.png',
    price: 0,
    serviceAreas: '',
    tags: [],
    joinTime: '',
    status: 1
  })
}

function handleSubmit() {
  formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        if (formData.id) {
          await updateHost(formData)
          ElMessage.success('修改成功')
        } else {
          await saveHost(formData)
          ElMessage.success('新增成功')
        }
        handleCloseDialog()
        fetchData()
      } finally {
        loading.value = false
      }
    }
  })
}

function handleDelete(id) {
  ElMessageBox.confirm('确认删除该主持人?', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    await deleteHost(id)
    ElMessage.success('删除成功')
    fetchData()
  })
}

// 导入相关方法
function handleOpenImportDialog() {
  importDialog.visible = true
}

function handleCloseImportDialog() {
  importDialog.visible = false
  uploadRef.value?.clearFiles()
  selectedFile.value = null
}

function handleFileChange(file, fileList) {
  if (fileList.length > 0) {
    selectedFile.value = file.raw
  } else {
    selectedFile.value = null
  }
}

function beforeUpload(file) {
  const isExcel = file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
                  file.type === 'application/vnd.ms-excel'
  const isLt10M = file.size / 1024 / 1024 < 10

  if (!isExcel) {
    ElMessage.error('只能上传 Excel 文件!')
    return false
  }
  if (!isLt10M) {
    ElMessage.error('上传文件大小不能超过 10MB!')
    return false
  }
  return true
}

async function handleImportSubmit() {
  if (!selectedFile.value) {
    ElMessage.warning('请先选择要导入的文件')
    return
  }
  
  importLoading.value = true
  try {
    const importFormData = new FormData()
    importFormData.append('file', selectedFile.value)
    
    await importHost(importFormData)
    ElMessage.success('导入成功')
    handleCloseImportDialog()
    fetchData()
  } catch (error) {
    ElMessage.error(error.message || '导入失败')
  } finally {
    importLoading.value = false
  }
}

function handleImportSuccess(response) {
  if (response.code === 200) {
    ElMessage.success('导入成功')
    handleCloseImportDialog()
    fetchData()
  } else {
    ElMessage.error(response.message || '导入失败')
  }
  importLoading.value = false
}

function handleImportError(error) {
  ElMessage.error('导入失败: ' + (error.message || '未知错误'))
  importLoading.value = false
}

// 审核操作
function handleAudit(id, action) {
  const actionText = action === 'approve' ? '通过' : '拒绝'
  ElMessageBox.confirm(`确认${actionText}该主持人的入驻申请?`, '审核确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: action === 'approve' ? 'success' : 'warning'
  }).then(async () => {
    await auditHost(id, action)
    ElMessage.success(`已${actionText}该入驻申请`)
    fetchData()
  }).catch(() => {})
}

// 查看入驻详情
function handleOpenAuditDetail(row) {
  auditDialog.data = { ...row }
  auditDialog.visible = true
}

// 格式化服务区域
function formatServiceAreas(areas) {
  if (!areas) return '-'
  try {
    const arr = JSON.parse(areas)
    return Array.isArray(arr) ? arr.join('、') : areas
  } catch {
    return areas
  }
}

async function handleDownloadTemplate() {
  try {
    const response = await downloadHostTemplate()
    // response 是 axios 响应对象，实际数据在 response.data 中
    const blob = new Blob([response.data], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = '主持人导入模板.xlsx'
    link.click()
    URL.revokeObjectURL(link.href)
    ElMessage.success('模板下载成功')
  } catch (error) {
    ElMessage.error('模板下载失败')
  }
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.tag-item {
  margin-right: 6px;
  margin-bottom: 4px;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  display: inline-block;
  text-align: center;
}

/* 确保标签在表格中正确换行 */
:deep(.el-table__cell) {
  line-height: 1.8;
}

.audit-images {
  display: flex;
  gap: 24px;
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
}

.audit-image-item {
  text-align: center;
}

.audit-image-label {
  font-size: 13px;
  color: #606266;
  margin-bottom: 8px;
}
</style>
